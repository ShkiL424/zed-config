#!/usr/bin/env python3
"""Validate JSON-with-comments files (Zed settings, keymaps, tasks, snippets).

Strips // and /* */ comments outside strings and trailing commas, then parses
with the standard json module. Usage: check-jsonc.py FILE [FILE...]
Exits non-zero if any file fails.
"""
import json
import re
import sys


def strip_comments(text: str) -> str:
    out = []
    i, n = 0, len(text)
    in_str = False
    while i < n:
        c = text[i]
        if in_str:
            out.append(c)
            if c == "\\" and i + 1 < n:
                out.append(text[i + 1])
                i += 2
                continue
            if c == '"':
                in_str = False
            i += 1
            continue
        if c == '"':
            in_str = True
            out.append(c)
            i += 1
        elif text.startswith("//", i):
            j = text.find("\n", i)
            i = n if j == -1 else j
        elif text.startswith("/*", i):
            j = text.find("*/", i + 2)
            if j == -1:
                raise ValueError("unterminated block comment")
            # keep newlines so line numbers in errors stay accurate
            out.append("\n" * text.count("\n", i, j))
            i = j + 2
        else:
            out.append(c)
            i += 1
    return "".join(out)


def strip_trailing_commas(text: str) -> str:
    # Safe after comment removal only for commas outside strings; Zed configs
    # don't contain ",}" or ",]" inside string values in practice.
    return re.sub(r",(\s*[}\]])", r"\1", text)


def main(paths):
    failed = False
    for path in paths:
        try:
            with open(path, encoding="utf-8") as f:
                json.loads(strip_trailing_commas(strip_comments(f.read())))
            print(f"ok    {path}")
        except (ValueError, OSError) as e:
            failed = True
            print(f"FAIL  {path}: {e}")
    return 1 if failed else 0


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__.strip())
        sys.exit(2)
    sys.exit(main(sys.argv[1:]))
