local cfg = require("config")
local commands = require("commands")

local function print_usage()
  print("Usage: " .. cfg.tool_name .. " <command> [args]")
  print("")
  print("Commands:")
  print("  new <name>    Create a new raygo project, add src/main.c, and init git")
  print("  build         Compile C files in " .. cfg.src_dir .. "/ into " .. cfg.build_dir .. "/" .. cfg.binary_name)
  print("  run           Compile and run the project")
  print("  doctor        Check compiler, git, raylib header, and linker setup")
end

local subcmd = arg[1]
local exit_code = 0

if subcmd == "new" then
  exit_code = commands.new_project(arg[2])
elseif subcmd == "build" then
  exit_code = commands.build()
elseif subcmd == "run" then
  exit_code = commands.run()
elseif subcmd == "doctor" then
  exit_code = commands.doctor()
elseif subcmd == nil or subcmd == "-h" or subcmd == "--help" then
  print_usage()
  exit_code = 0
else
  io.stderr:write("Unknown command '" .. tostring(subcmd) .. "'.\n\n")
  print_usage()
  exit_code = 1
end

os.exit(exit_code)
