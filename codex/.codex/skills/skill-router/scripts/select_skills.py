#!/usr/bin/env python3
"""Rank installed Codex skills for a task without injecting the full catalog."""

from __future__ import annotations

import argparse
import math
import os
import re
import subprocess
from dataclasses import dataclass
from pathlib import Path

WORD_RE = re.compile(r"[a-z0-9]+")
STOP_WORDS = {
    "a",
    "an",
    "and",
    "are",
    "as",
    "at",
    "be",
    "by",
    "do",
    "for",
    "from",
    "how",
    "i",
    "in",
    "is",
    "it",
    "make",
    "my",
    "of",
    "on",
    "or",
    "the",
    "this",
    "to",
    "use",
    "want",
    "when",
    "with",
}


@dataclass(frozen=True)
class Skill:
    name: str
    description: str
    path: Path


def normalize(text: str):
    return " ".join(WORD_RE.findall(text.lower()))


def terms(text: str):
    return [term for term in WORD_RE.findall(text.lower()) if term not in STOP_WORDS]


def unquote(value: str):
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {'"', "'"}:
        return value[1:-1]
    return value


def parse_frontmatter(path: Path):
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return None

    if not text.startswith("---"):
        return None

    parts = text.split("---", 2)
    if len(parts) < 3:
        return None

    lines = parts[1].splitlines()
    values: dict[str, str] = {}
    index = 0
    while index < len(lines):
        match = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", lines[index])
        if not match:
            index += 1
            continue

        key, value = match.groups()
        if value in {">", ">-", "|", "|-"}:
            block: list[str] = []
            index += 1
            while index < len(lines) and (not lines[index].strip() or lines[index][:1].isspace()):
                block.append(lines[index].strip())
                index += 1
            values[key] = " ".join(part for part in block if part)
            continue

        value = unquote(value)
        index += 1
        if key == "description":
            continuation: list[str] = []
            while index < len(lines) and lines[index][:1].isspace():
                continuation.append(lines[index].strip())
                index += 1
            if continuation:
                value = " ".join([value, *continuation])
        values[key] = value

    name = values.get("name", "").strip()
    description = values.get("description", "").strip()
    if not name or not description:
        return None
    return Skill(name=name, description=description, path=path.resolve())


def project_skill_roots(cwd: Path):
    try:
        result = subprocess.run(
            ["git", "-C", str(cwd), "rev-parse", "--show-toplevel"],
            check=True,
            capture_output=True,
            text=True,
        )
        boundary = Path(result.stdout.strip()).resolve()
    except (OSError, subprocess.CalledProcessError):
        boundary = cwd.anchor and Path(cwd.anchor) or cwd

    roots: list[Path] = []
    current = cwd.resolve()
    while True:
        roots.append(current / ".agents" / "skills")
        if current == boundary or current.parent == current:
            break
        current = current.parent
    return roots


def walk_skill_files(root: Path):
    if not root.is_dir():
        return

    visited_dirs: set[Path] = set()
    for directory, dirnames, filenames in os.walk(root, followlinks=True):
        resolved_directory = Path(directory).resolve()
        if resolved_directory in visited_dirs:
            dirnames[:] = []
            continue
        visited_dirs.add(resolved_directory)
        if "SKILL.md" in filenames:
            yield Path(directory) / "SKILL.md"


def discover_skills(cwd: Path):
    codex_home = Path(os.environ.get("CODEX_HOME", Path.home() / ".codex")).expanduser()
    roots = [
        *project_skill_roots(cwd),
        codex_home / "skills",
        Path.home() / ".agents" / "skills",
        codex_home / "plugins" / "cache",
    ]

    skills: list[Skill] = []
    seen_paths: set[Path] = set()
    for root in roots:
        for path in walk_skill_files(root):
            resolved = path.resolve()
            if resolved in seen_paths:
                continue
            seen_paths.add(resolved)
            skill = parse_frontmatter(path)
            if skill:
                skills.append(skill)
    return skills


def rank_skills(skills: list[Skill], query: str):
    query_terms = terms(query)
    if not query_terms:
        return []

    document_frequency: dict[str, int] = {}
    searchable: list[tuple[Skill, list[str], list[str]]] = []
    for skill in skills:
        name_terms = terms(skill.name.replace("-", " "))
        description_terms = terms(skill.description)
        searchable.append((skill, name_terms, description_terms))
        for term in set(name_terms + description_terms):
            document_frequency[term] = document_frequency.get(term, 0) + 1

    total = max(len(skills), 1)
    normalized_query = normalize(query)
    ranked: list[tuple[float, Skill]] = []
    for skill, name_terms, description_terms in searchable:
        normalized_name = normalize(skill.name.replace("-", " "))
        normalized_description = normalize(skill.description)
        name_counts = {term: name_terms.count(term) for term in set(name_terms)}
        description_counts = {
            term: description_terms.count(term) for term in set(description_terms)
        }
        score = 0.0

        if normalized_name and normalized_name in normalized_query:
            score += 18.0

        for term in query_terms:
            frequency = document_frequency.get(term, 0)
            inverse_frequency = math.log((total + 1) / (frequency + 1)) + 1
            score += 7.0 * inverse_frequency * min(name_counts.get(term, 0), 2)
            score += 2.2 * inverse_frequency * min(description_counts.get(term, 0), 3)

            if len(term) >= 4 and term not in name_counts and term in normalized_name:
                score += 2.0
            if len(term) >= 5 and term not in description_counts and term in normalized_description:
                score += 0.6

        matched_terms = sum(
            1
            for term in set(query_terms)
            if term in name_counts or term in description_counts
        )
        score += 1.5 * matched_terms * matched_terms / len(set(query_terms))

        if score > 0:
            ranked.append((score, skill))

    ranked.sort(key=lambda item: (-item[0], item[1].name, str(item[1].path)))
    unique: list[tuple[float, Skill]] = []
    seen_names: set[str] = set()
    for item in ranked:
        canonical_name = item[1].name.casefold()
        if canonical_name in seen_names:
            continue
        seen_names.add(canonical_name)
        unique.append(item)
    return unique


def main():
    parser = argparse.ArgumentParser(
        description="Find the installed skills most relevant to a task."
    )
    parser.add_argument("query", nargs="+", help="Task or focused capability query")
    parser.add_argument("--cwd", type=Path, default=Path.cwd(), help="Project directory")
    parser.add_argument("--limit", type=int, default=6, help="Maximum matches")
    parser.add_argument("--all", action="store_true", help="List every discovered skill")
    args = parser.parse_args()

    skills = discover_skills(args.cwd)
    if args.all:
        ranked = [(0.0, skill) for skill in sorted(skills, key=lambda item: item.name)]
    else:
        ranked = rank_skills(skills, " ".join(args.query))[: max(args.limit, 1)]

    if not ranked:
        print("No matching installed skills found.")
        return

    print(f"Discovered {len(skills)} skills; showing {len(ranked)} match(es):")
    for score, skill in ranked:
        score_text = "" if args.all else f" score={score:.2f}"
        print(f"\n- {skill.name}{score_text}")
        print(f"  path: {skill.path}")
        print(f"  description: {skill.description}")


if __name__ == "__main__":
    main()
