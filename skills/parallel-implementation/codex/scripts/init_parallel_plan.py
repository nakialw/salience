#!/usr/bin/env python3

import argparse
import re
import subprocess
from datetime import datetime
from pathlib import Path


def normalize_slug(value: str) -> str:
    slug = value.strip().lower()
    slug = re.sub(r"[^a-z0-9]+", "-", slug)
    slug = re.sub(r"-{2,}", "-", slug).strip("-")
    return slug or "parallel-task"


def current_branch(base_dir: Path) -> str:
    try:
        result = subprocess.run(
            ["git", "-C", str(base_dir), "branch", "--show-current"],
            check=True,
            capture_output=True,
            text=True,
        )
    except (FileNotFoundError, subprocess.CalledProcessError):
        return "N/A"
    branch = result.stdout.strip()
    return branch or "N/A"


def main() -> None:
    parser = argparse.ArgumentParser(description="Initialize a wave-based implementation plan.")
    parser.add_argument("--task", required=True, help="Human-readable task name or slug.")
    parser.add_argument("--base-dir", default=".", help="Repository or working root.")
    parser.add_argument("--force", action="store_true", help="Overwrite an existing plan file.")
    args = parser.parse_args()

    skill_dir = Path(__file__).resolve().parent.parent
    base_dir = Path(args.base_dir).resolve()
    task_slug = normalize_slug(args.task)
    created_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    branch = current_branch(base_dir)

    plan_dir = base_dir / "plans" / task_slug
    plan_dir.mkdir(parents=True, exist_ok=True)
    plan_path = plan_dir / "plan.md"

    if plan_path.exists() and not args.force:
        print(plan_path)
        return

    template = (skill_dir / "assets" / "parallel-task-plan.md").read_text()
    content = (
        template.replace("{{TASK_NAME}}", args.task)
        .replace("{{TASK_SLUG}}", task_slug)
        .replace("{{CREATED_AT}}", created_at)
        .replace("{{BRANCH}}", branch)
    )
    plan_path.write_text(content)
    print(plan_path)


if __name__ == "__main__":
    main()
