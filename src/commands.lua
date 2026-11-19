local cfg = require("config")
local sys = require("sys")

local M = {}

-- Checks compiler, git, raylib header, and a live test link against raylib/Linux libs.
function M.doctor()
  local ok_all = true
  print("[" .. cfg.tool_name .. "] Checking Linux raylib environment...\n")

  local has_cc = sys.run_cmd("command -v " .. sys.shell_quote(cfg.c_compiler) .. " >/dev/null 2>&1")
  local has_git = sys.run_cmd("command -v git >/dev/null 2>&1")
  local has_header = sys.file_exists("/usr/local/include/raylib.h") or sys.file_exists("/usr/include/raylib.h")

  print("  Compiler (" .. cfg.c_compiler .. "): " .. (has_cc and "OK" or "MISSING"))
  if not has_cc then ok_all = false end

  print("  Git:                " .. (has_git and "OK" or "MISSING"))
  if not has_git then ok_all = false end

  print("  raylib.h:         " .. (has_header and "OK (system include)" or "NOT FOUND in /usr/include or /usr/local/include"))

  local link_ok = false
  if has_cc then
    local probe = string.format(
      "printf '#include <raylib.h>\\nint main(void){return 0;}\\n' | %s -x c - -o /tmp/raygo_probe %s >/dev/null 2>&1",
      cfg.c_compiler,
      cfg.raylib_libs
    )
    link_ok = sys.run_cmd(probe)
    sys.run_cmd("rm -f /tmp/raygo_probe")
  end

  print("  Raylib link test:   " .. (link_ok and "OK" or "FAILED"))
  if not link_ok then ok_all = false end

  print("")
  if ok_all then
    print("All checks passed! Ready to build raylib projects.")
    return 0
  end

  print("Missing dependencies detected. Suggested install command:")
  print("  " .. sys.distro_install_hint())
  return 1
end

-- Creates `<name>`, `<name>/src`, `<name>/build`, writes `src/main.c`, and runs `git init`.
function M.new_project(project_name)
  if not project_name or project_name == "" then
    io.stderr:write("Usage: " .. cfg.tool_name .. " new <project_name>\n")
    return 1
  end

  local src_path = project_name .. "/" .. cfg.src_dir
  local build_path = project_name .. "/" .. cfg.build_dir
  local main_path = src_path .. "/main.c"

  if sys.file_exists(main_path) then
    io.stderr:write("Error: Project '" .. project_name .. "' already exists.\n")
    return 1
  end

  local mkdir_cmd = string.format(
    "mkdir -p %s %s",
    sys.shell_quote(src_path),
    sys.shell_quote(build_path)
  )
  if not sys.run_cmd(mkdir_cmd) then
    io.stderr:write("Error: Failed to create project directories.\n")
    return 1
  end

  local ok_main, err_main = sys.write_file(main_path, cfg.starter_main_c)
  if not ok_main then
    io.stderr:write("Error: " .. err_main .. "\n")
    return 1
  end

  -- Editor/clangd support & git ignore for build output
  sys.write_file(project_name .. "/compile_flags.txt", "-Wall\n-Wextra\n" .. cfg.c_std .. "\n-I" .. cfg.src_dir .. "\n")
  sys.write_file(project_name .. "/.gitignore", cfg.build_dir .. "/\n*.o\n")

  local git_ok = sys.run_cmd("git -C " .. sys.shell_quote(project_name) .. " init -q")
  if not git_ok then
    io.stderr:write("Warning: Created project, but `git init` failed.\n")
  end

  print("Created raygo project '" .. project_name .. "' with " .. cfg.src_dir .. "/main.c" .. (git_ok and " and initialized Git." or "."))
  return 0
end

-- Compiles all .c files in `src/` into `build/<binary_name>`.
function M.build()
  local main_path = cfg.src_dir .. "/main.c"
  if not sys.file_exists(main_path) then
    io.stderr:write("Error: Could not find " .. main_path .. ". Run this inside a project created with `" .. cfg.tool_name .. " new`.\n")
    return 1
  end

  sys.run_cmd("mkdir -p " .. sys.shell_quote(cfg.build_dir))

  local found = sys.capture_cmd("find " .. sys.shell_quote(cfg.src_dir) .. " -type f -name '*.c'") or ""
  local c_files = {}
  for path in found:gmatch("[^\r\n]+") do
    table.insert(c_files, sys.shell_quote(path))
  end

  if #c_files == 0 then
    table.insert(c_files, sys.shell_quote(main_path))
  end

  local out_bin = cfg.build_dir .. "/" .. cfg.binary_name
  local cmd = string.format(
    "%s -Wall -Wextra %s %s -I%s %s -o %s %s",
    cfg.c_compiler,
    cfg.c_std,
    cfg.opt_flag,
    sys.shell_quote(cfg.src_dir),
    table.concat(c_files, " "),
    sys.shell_quote(out_bin),
    cfg.raylib_libs
  )

  print("[" .. cfg.tool_name .. "] Compiling " .. out_bin .. "...")
  if not sys.run_cmd(cmd) then
    io.stderr:write("[" .. cfg.tool_name .. "] Compilation failed.\n")
    return 1
  end

  print("[" .. cfg.tool_name .. "] Compiled successfully -> " .. out_bin)
  return 0
end

-- Compiles the project and runs it.
function M.run()
  local build_code = M.build()
  if build_code ~= 0 then
    return build_code
  end

  local bin_path = "./" .. cfg.build_dir .. "/" .. cfg.binary_name
  print("[" .. cfg.tool_name .. "] Running " .. bin_path .. "...\n")
  if not sys.run_cmd(sys.shell_quote(bin_path)) then
    return 1
  end
  return 0
end

return M
