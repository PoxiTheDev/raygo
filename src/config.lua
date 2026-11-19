-- This holds names, linker flags, and a main.c template, all of which should be customizable to your liking
local M = {
  tool_name = "raygo",
  src_dir = "src",
  build_dir = "build",
  binary_name = "game",
  c_compiler = "gcc",
  c_std = "-std=c11",
  opt_flag = "-O2",
  default_window_title = "Raylib Project",
  raylib_libs = "-lraylib -lGL -lm -lpthread -ldl -lrt -lX11",
}

M.starter_main_c = [[
#include "raylib.h"

int main(void) {
    InitWindow(800, 600, "]] .. M.default_window_title .. [[");
    SetTargetFPS(60);

    while (!WindowShouldClose()) {
        BeginDrawing();
        ClearBackground(RAYWHITE);
        DrawText("Hello from raygo + raylib!", 220, 280, 24, BLACK);
        EndDrawing();
    }

    CloseWindow();
    return 0;
}
]]

return M
