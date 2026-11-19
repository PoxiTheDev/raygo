#!/usr/bin/env sh

if command -v readlink >/dev/null 2>&1; then
  SCRIPT_PATH="$(readlink -f -- "$0" 2>/dev/null || printf '%s' "$0")"
else
  SCRIPT_PATH="$0"
fi

# Resolves the directory containing raygo.sh (should work symlinked)
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"
ENTRY="$SRC_DIR/main.lua"

# Make sure Lua can get the stuffw from src/
export LUA_PATH="$SRC_DIR/?.lua;$SRC_DIR/?/init.lua;${LUA_PATH:-;;}"

if command -v luajit >/dev/null 2>&1; then
  exec luajit "$ENTRY" "$@"
elif command -v lua >/dev/null 2>&1; then
  exec lua "$ENTRY" "$@"
else
  echo "Error: Neither 'lua' nor 'luajit' was found in PATH." >&2
  exit 1
fi
