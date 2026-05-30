#!/usr/bin/env python3

import argparse
import json
import re
from datetime import datetime
from pathlib import Path


def normalize_slug(value: str) -> str:
    slug = value.strip().lower()
    slug = re.sub(r"[^a-z0-9]+", "-", slug)
    slug = re.sub(r"-{2,}", "-", slug).strip("-")
    return slug or "ensemble-task"


def load_asset(skill_dir: Path, name: str) -> str:
    return (skill_dir / "assets" / name).read_text()


def render_template(content: str, replacements: dict[str, str]) -> str:
    rendered = content
    for key, value in replacements.items():
        rendered = rendered.replace(f"{{{{{key}}}}}", value)
    return rendered


def parse_models(value: str) -> list[str]:
    models = [item.strip() for item in value.split(",") if item.strip()]
    return models or ["codex", "claude", "gemini"]


def main() -> None:
    parser = argparse.ArgumentParser(description="Initialize an ensemble review run directory.")
    parser.add_argument("--slug", required=True, help="Short task slug used for output paths.")
    parser.add_argument("--mode", default="research", help="Review mode label.")
    parser.add_argument(
        "--posture",
        default="standard-consensus",
        help="Review posture label. Examples: standard-consensus, dissent-first, adjudication.",
    )
    parser.add_argument(
        "--models",
        default="codex,claude,gemini",
        help="Comma-separated model list used to seed output files and metadata.",
    )
    parser.add_argument("--base-dir", default=".", help="Repository or working root.")
    args = parser.parse_args()

    skill_dir = Path(__file__).resolve().parent.parent
    base_dir = Path(args.base_dir).resolve()
    slug = normalize_slug(args.slug)
    posture = normalize_slug(args.posture)
    models = parse_models(args.models)
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")

    if (base_dir / "plans").exists():
        run_dir = base_dir / "plans" / slug / "ensemble" / timestamp
    else:
        run_dir = base_dir / "reports" / "ensemble" / f"{timestamp}-{slug}"

    run_dir.mkdir(parents=True, exist_ok=True)

    prompt_template = load_asset(skill_dir, "shared-prompt-template.md")
    summary_template = load_asset(skill_dir, "summary-template.md")
    model_list = ", ".join(f"`{model}`" for model in models)
    raw_outputs = "\n".join(f"- `{normalize_slug(model)}.md`" for model in models)
    replacements = {
        "SLUG": slug,
        "MODE": args.mode,
        "POSTURE": posture,
        "MODELS": model_list,
        "RAW_OUTPUTS": raw_outputs,
    }

    (run_dir / "prompt.md").write_text(render_template(prompt_template, replacements))
    (run_dir / "summary.md").write_text(render_template(summary_template, replacements))

    for model_name in models:
        file_stem = normalize_slug(model_name)
        path = run_dir / f"{file_stem}.md"
        path.write_text(f"# {model_name.title()} Output\n\nPending run.\n")

    metadata = {
        "slug": slug,
        "mode": args.mode,
        "posture": posture,
        "models": models,
        "timestamp": timestamp,
        "base_dir": str(base_dir),
        "run_dir": str(run_dir),
    }
    (run_dir / "metadata.json").write_text(json.dumps(metadata, indent=2) + "\n")

    print(run_dir)


if __name__ == "__main__":
    main()
