#include <ApplicationServices/ApplicationServices.h>
#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include <spawn.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/file.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>

extern char **environ;

static const char *sketchybar_paths[] = {
    "/opt/homebrew/bin/sketchybar",
    "/usr/local/bin/sketchybar",
};

static pid_t sketchybar_child = -1;
static pthread_mutex_t reconcile_lock = PTHREAD_MUTEX_INITIALIZER;
static char user_id[32];

static int run_and_wait(const char *path, char *const argv[]) {
  posix_spawn_file_actions_t actions;
  posix_spawn_file_actions_init(&actions);
  posix_spawn_file_actions_addopen(
      &actions, STDOUT_FILENO, "/dev/null", O_WRONLY, 0);
  posix_spawn_file_actions_addopen(
      &actions, STDERR_FILENO, "/dev/null", O_WRONLY, 0);

  pid_t pid = -1;
  int spawn_result = posix_spawn(&pid, path, &actions, NULL, argv, environ);
  posix_spawn_file_actions_destroy(&actions);
  if (spawn_result != 0) {
    return -1;
  }

  int status = 0;
  pid_t wait_result;
  do {
    wait_result = waitpid(pid, &status, 0);
  } while (wait_result == -1 && errno == EINTR);

  if (wait_result == -1) {
    return -1;
  }

  return WIFEXITED(status) ? WEXITSTATUS(status) : -1;
}

static bool sketchybar_is_running(void) {
  char *const argv[] = {"pgrep", "-u", user_id, "-x", "sketchybar", NULL};
  return run_and_wait("/usr/bin/pgrep", argv) == 0;
}

static void reap_sketchybar(void) {
  if (sketchybar_child <= 0) {
    return;
  }

  pid_t result = waitpid(sketchybar_child, NULL, WNOHANG);
  if (result == sketchybar_child || (result == -1 && errno == ECHILD)) {
    sketchybar_child = -1;
  }
}

static bool external_display_is_connected(bool *has_external) {
  uint32_t count = 0;
  if (CGGetOnlineDisplayList(0, NULL, &count) != kCGErrorSuccess) {
    return false;
  }
  // Display topology may be temporarily empty during sleep or reconfiguration.
  // Preserve the current bar state until macOS has a usable display list again.
  if (count == 0) {
    return false;
  }

  CGDirectDisplayID *displays = calloc(count, sizeof(*displays));
  if (count > 0 && displays == NULL) {
    return false;
  }

  CGError result = CGGetOnlineDisplayList(count, displays, &count);
  if (result != kCGErrorSuccess) {
    free(displays);
    return false;
  }

  *has_external = false;
  for (uint32_t index = 0; index < count; index++) {
    if (CGDisplayIsBuiltin(displays[index]) == 0) {
      *has_external = true;
      break;
    }
  }

  free(displays);
  return true;
}

static const char *find_sketchybar(void) {
  size_t count = sizeof(sketchybar_paths) / sizeof(sketchybar_paths[0]);
  for (size_t index = 0; index < count; index++) {
    if (access(sketchybar_paths[index], X_OK) == 0) {
      return sketchybar_paths[index];
    }
  }
  return NULL;
}

static void start_sketchybar(void) {
  if (sketchybar_child > 0 || sketchybar_is_running()) {
    return;
  }

  const char *path = find_sketchybar();
  if (path == NULL) {
    return;
  }

  char *const argv[] = {"sketchybar", NULL};
  posix_spawn_file_actions_t actions;
  posix_spawn_file_actions_init(&actions);
  posix_spawn_file_actions_addopen(
      &actions, STDOUT_FILENO, "/dev/null", O_WRONLY, 0);
  posix_spawn_file_actions_addopen(
      &actions, STDERR_FILENO, "/dev/null", O_WRONLY, 0);
  int spawn_result = posix_spawn(
      &sketchybar_child, path, &actions, NULL, argv, environ);
  posix_spawn_file_actions_destroy(&actions);
  if (spawn_result != 0) {
    fprintf(stderr, "SketchyBar display controller: start failed: %s\n",
            strerror(spawn_result));
    sketchybar_child = -1;
  }
}

static void stop_sketchybar(void) {
  if (!sketchybar_is_running()) {
    return;
  }

  char *const argv[] = {"pkill", "-u", user_id, "-x", "sketchybar", NULL};
  (void)run_and_wait("/usr/bin/pkill", argv);
  // Keep the PID until the process actually exits; a later check will reap it.
  reap_sketchybar();
}

static void reconcile_sketchybar(void) {
  pthread_mutex_lock(&reconcile_lock);
  reap_sketchybar();

  bool has_external = false;
  if (!external_display_is_connected(&has_external)) {
    fprintf(stderr, "SketchyBar display controller: unable to read displays\n");
    pthread_mutex_unlock(&reconcile_lock);
    return;
  }

  static int previous_external = -1;
  if (previous_external != (int)has_external) {
    fprintf(
        stderr,
        "SketchyBar display controller: external display %s; bar %s\n",
        has_external ? "connected" : "not connected",
        has_external ? "off" : "on");
    previous_external = (int)has_external;
  }

  if (has_external) {
    stop_sketchybar();
  } else {
    start_sketchybar();
  }

  pthread_mutex_unlock(&reconcile_lock);
}

static void periodic_reconcile(CFRunLoopTimerRef timer, void *user_info) {
  (void)timer;
  (void)user_info;
  reconcile_sketchybar();
}

static void display_configuration_changed(
    CGDirectDisplayID display,
    CGDisplayChangeSummaryFlags flags,
    void *user_info) {
  (void)display;
  (void)user_info;

  if ((flags & kCGDisplayBeginConfigurationFlag) == 0) {
    reconcile_sketchybar();
  }
}

static int acquire_singleton_lock(void) {
  const char *temporary_directory = getenv("TMPDIR");
  if (temporary_directory == NULL || temporary_directory[0] == '\0') {
    temporary_directory = "/tmp";
  }

  char lock_path[1024];
  int length = snprintf(
      lock_path,
      sizeof(lock_path),
      "%s/sketchybar-display-controller-%u.lock",
      temporary_directory,
      (unsigned)getuid());
  if (length < 0 || (size_t)length >= sizeof(lock_path)) {
    return -1;
  }

  // The bar must not inherit this lock and prevent a controller restart.
  int descriptor = open(lock_path, O_CREAT | O_RDWR | O_CLOEXEC, S_IRUSR | S_IWUSR);
  if (descriptor < 0 || flock(descriptor, LOCK_EX | LOCK_NB) != 0) {
    if (descriptor >= 0) {
      close(descriptor);
    }
    return -1;
  }

  return descriptor;
}

int main(void) {
  snprintf(user_id, sizeof(user_id), "%u", (unsigned)getuid());
  int lock_descriptor = acquire_singleton_lock();
  if (lock_descriptor < 0) {
    return EXIT_SUCCESS;
  }

  if (CGDisplayRegisterReconfigurationCallback(
          display_configuration_changed,
          NULL) != kCGErrorSuccess) {
    close(lock_descriptor);
    return EXIT_FAILURE;
  }

  // Callbacks handle plug/unplug immediately. The timer also recovers from a
  // missed event, a wake-up race, or SketchyBar exiting while using only the Mac.
  CFRunLoopTimerRef timer = CFRunLoopTimerCreate(
      kCFAllocatorDefault, CFAbsoluteTimeGetCurrent() + 2.0, 2.0, 0, 0,
      periodic_reconcile, NULL);
  if (timer == NULL) {
    CGDisplayRemoveReconfigurationCallback(display_configuration_changed, NULL);
    close(lock_descriptor);
    return EXIT_FAILURE;
  }
  CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes);

  reconcile_sketchybar();
  CFRunLoopRun();
  CFRunLoopTimerInvalidate(timer);
  CFRelease(timer);
  CGDisplayRemoveReconfigurationCallback(display_configuration_changed, NULL);
  close(lock_descriptor);
  return EXIT_SUCCESS;
}
