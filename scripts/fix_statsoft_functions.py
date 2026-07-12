#!/usr/bin/env python3
"""
Fix statsoft_reveal() and statsoft_verify() function definitions in shell scripts.
Moves them to top-level (column 0, outside any function body) when they are:
  - Indented (have leading whitespace)
  - Defined inside another function body (depth > 0)
"""

import os
import re
import subprocess
import sys

SKILL_ROOT = "C:/Users/WintoneFileSrv/.workbuddy/skills/statsoft-cli/scripts"

# Pattern to match statsoft_reveal or statsoft_verify FUNCTION DEFINITIONS only.
# Matches lines like: statsoft_reveal() { [ "${STATSOFT_REVEAL:-0}" = "1" ]; }
# Does NOT match function calls like: if statsoft_reveal; then
FUNC_DEF_PATTERN = re.compile(
    r'^(?P<indent>\s*)statsoft_(?:reveal|verify)\s*\(\)\s*\{'
)


def is_in_heredoc(lines, target_line_num):
    """Check if a given line number is inside a heredoc block."""
    if target_line_num < 0 or target_line_num >= len(lines):
        return False
    in_heredoc = False
    heredoc_end = None
    for i in range(target_line_num):
        line = lines[i]
        if in_heredoc:
            stripped = line.strip()
            if stripped == heredoc_end or stripped.startswith(heredoc_end + '$'):
                in_heredoc = False
        else:
            # Check for heredoc start: <<EOF, <<'EOF', <<-EOF, etc.
            hm = re.search(r'<<-?\s*[\'"]?(\w+)[\'"]?', line)
            if hm:
                in_heredoc = True
                heredoc_end = hm.group(1)
    return in_heredoc


def get_brace_depth_at_line(lines, target_line_num):
    """
    Calculate the brace nesting depth at a given line number.
    Lines inside heredocs are not counted.
    """
    depth = 0
    in_heredoc = False
    heredoc_end = None
    for i in range(target_line_num):
        line = lines[i]
        if in_heredoc:
            if line.strip() == heredoc_end:
                in_heredoc = False
        else:
            # Check for heredoc start
            hm = re.search(r'<<-?\s*[\'"]?(\w+)[\'"]?', line)
            if hm:
                in_heredoc = True
                heredoc_end = hm.group(1)
            else:
                # Count braces (simple heuristic: count { and })
                # This works for single-line function definitions
                depth += line.count('{') - line.count('}')
                if depth < 0:
                    depth = 0
    return depth


def find_definitions(lines):
    """Find all statsoft_reveal/verify function definitions in the file."""
    definitions = []
    for i, line in enumerate(lines):
        m = FUNC_DEF_PATTERN.match(line)
        if m:
            definitions.append({
                'line_num': i,
                'indent': m.group('indent'),
                'content': line.rstrip('\n').rstrip('\r'),
            })
    return definitions


def needs_fix(lines, definitions):
    """Check if any definition is indented or inside a function body."""
    for d in definitions:
        # Check indentation (non-empty indent means indented)
        if d['indent']:
            return True
        # Check if inside a function body (depth > 0)
        depth = get_brace_depth_at_line(lines, d['line_num'])
        if depth > 0:
            return True
        # Check if inside a heredoc (these need fixing too)
        if is_in_heredoc(lines, d['line_num']):
            return True
    return False


def process_file(filepath):
    """
    Process a single shell script file.
    Returns: (was_modified, message)
    """
    with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
        lines = f.readlines()

    definitions = find_definitions(lines)
    if not definitions:
        return False, "No definitions found"

    if not needs_fix(lines, definitions):
        return False, "No fixes needed (all definitions at top-level, no indent)"

    # Remove the definitions from their current positions (reverse order)
    definition_texts = [d['content'].strip() for d in definitions]
    sorted_defs_sorted = sorted(definitions, key=lambda x: x['line_num'], reverse=True)
    for d in sorted_defs_sorted:
        del lines[d['line_num']]

    # Remove any resulting empty duplicate lines (don't leave gaps)
    # Actually we should keep the structure clean, so let's just remove blank lines
    # that were left after deletion if they're between existing blank lines
    # For simplicity, we'll leave the blank lines as is.

    # Find the best insertion point: after LANG_ZH() definition
    insert_idx = 0
    for i, line in enumerate(lines):
        # Match LANG_ZH at top level (column 0)
        if re.match(r'^LANG_ZH\s*\(\)', line):
            insert_idx = i + 1
            break

    # Insert the definitions at the found position
    for j, text in enumerate(definition_texts):
        lines.insert(insert_idx + j, text + '\n')

    # Write back with original line endings
    with open(filepath, 'w', encoding='utf-8', newline='') as f:
        f.writelines(lines)

    return True, f"Fixed {len(definitions)} definitions (moved to top-level)"


def verify_with_bash(filepath):
    """Run bash -n to verify syntax. Returns (success, stderr)."""
    # Convert Windows path to forward slashes for bash
    bash_path = filepath.replace('\\', '/')
    result = subprocess.run(
        ['bash', '-n', bash_path],
        capture_output=True,
        text=True
    )
    return result.returncode == 0, result.stderr


def find_all_sh_files():
    """Find all .sh files in cross-platform and windows-only directories."""
    files = []
    for subdir in ['cross-platform', 'windows-only']:
        base = os.path.join(SKILL_ROOT, subdir)
        if not os.path.isdir(base):
            continue
        for root, dirs, filenames in os.walk(base):
            for fn in filenames:
                if fn.endswith('.sh'):
                    files.append(os.path.join(root, fn))
    return sorted(files)


def main():
    files = find_all_sh_files()
    print(f"Found {len(files)} .sh files to scan\n")

    modified_count = 0
    error_count = 0

    for filepath in files:
        rel_path = os.path.relpath(filepath, SKILL_ROOT)
        try:
            modified, msg = process_file(filepath)
            if modified:
                # Verify with bash -n after modification
                ok, stderr = verify_with_bash(filepath)
                status = "✓ PASS" if ok else "✗ FAIL"
                print(f"{status} | {rel_path}: {msg}")
                if not ok:
                    print(f"         bash -n error: {stderr.strip()}")
                    error_count += 1
                modified_count += 1
            else:
                # Uncomment for verbose output:
                # print(f"  skip | {rel_path}: {msg}")
                pass
        except Exception as e:
            print(f"✗ ERROR | {rel_path}: {e}")
            error_count += 1

    print(f"\n{'='*60}")
    print(f"Total files scanned: {len(files)}")
    print(f"Files modified: {modified_count}")
    print(f"Errors: {error_count}")

    return 0 if error_count == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
