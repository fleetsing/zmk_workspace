#!/usr/bin/env python3
"""PreToolUse hook: require confirmation before file edits inside the pinned ../zmk checkout.

Claude Code permission rules can't express a path relative to a sibling of the
project, so this resolves the target against $CLAUDE_PROJECT_DIR instead.
"""
import json
import os
import sys

payload = json.load(sys.stdin)
tool_input = payload.get("tool_input", {})
target = tool_input.get("file_path") or tool_input.get("notebook_path")
if not target:
    sys.exit(0)

project_dir = os.environ.get("CLAUDE_PROJECT_DIR") or payload.get("cwd") or os.getcwd()
upstream = os.path.realpath(os.path.join(project_dir, "..", "zmk"))
target = os.path.realpath(os.path.join(payload.get("cwd") or project_dir, target))

if target == upstream or target.startswith(upstream + os.sep):
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "ask",
            "permissionDecisionReason": "../zmk is the pinned upstream reference checkout. Approve only if this task is explicitly about patching upstream ZMK.",
        }
    }))
