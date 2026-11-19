-- Wrapper for OS commands, file writes, quoting and distro stuff.
local M = {}

-- Runs a shell command and returns true on exit code 0.
function M.run_cmd(cmd)
  local ok = os.execute(cmd)
  return ok == true or ok == 0
end

-- Runs a shell command and captures stdout.
function M.capture_cmd(cmd)
  local handle = io.popen(cmd .. " 2>/dev/null")
  if not handle then
    return nil
  end
  local out = handle:read("*a")
  handle:close()
  return out
end

-- Checks whether a readable file exists at `path`.
function M.file_exists(path)
  local f = io.open(path, "r")
  if f then
    f:close()
    return true
  end
  return false
end

-- Wraps a string in double quotes.
function M.shell_quote(str)
  return '"' .. tostring(str):gsub('\\', '\\\\'):gsub('"', '\\"') .. '"'
end

-- Writes `content` to `path`.
function M.write_file(path, content, mode)
  mode = mode or "w"
  local f, err = io.open(path, mode)
  if not f then
    return false, "Failed to open '" .. path .. "': " .. tostring(err)
  end
  f:write(content)
  f:close()
  return true
end

-- Suggests a package install command for common Linux distributions.
function M.distro_install_hint()
  if M.file_exists("/etc/debian_version") then
    return "sudo apt update && sudo apt install build-essential git libasound2-dev libx11-dev libxrandr-dev libxi-dev libgl1-mesa-dev libglu1-mesa-dev libxcursor-dev libxinerama-dev"
  elseif M.file_exists("/etc/arch-release") then
    return "sudo pacman -S base-devel git raylib"
  elseif M.file_exists("/etc/fedora-release") then
    return "sudo dnf install @development-tools git raylib-devel"
  end
  return "Install a C compiler, git, raylib, and X11/OpenGL/ALSA development headers via your package manager."
end

return M
