# Raygo

Cargo-like project for raylib on linux i did for myself because im sick and tired of the way i have to do it everytime.
Essentially what this does is it inits a git repo, makes an example raylib project, and checks if you have all the dependencies.
Also i am not responsible for whatever happens while using this thing,i give you no warranty this will even work.
SOME PARTS OF THE CODE, SPECIFICALLY SOME OF sys.lua HAS BEEN MADE WITH HELP OF GENERATIVE AI.

## Setup instructions

### 0. Make sure raylib is downloaded

### 1. Make raygo run from anywhere without typing out the entire path (OPTIONAL)
  ``` bash
    chmod +x ~/Documents/raygo/raygo.sh
    mkdir -p ~/.local/bin
    rm -f ~/.local/bin/raygo
    cat <<'EOF' > ~/.local/bin/raygo
    #!/usr/bin/env sh
    exec /home/poxi/Documents/raygo/raygo.sh "$@"
    EOF
    chmod +x ~/.local/bin/raygo
    hash -r
  ```

### 2. Check dependencies
  ``` bash
    raygo doctor
  ```

### 3. Create a new project (creates my-game/, my-game/src/main.c, my-game/build/, compile-flags.txt, and initializes a git repo)
  ``` bash
    raygo new my_game
  ```

### 4. Compile it
  ``` bash
    raygo run
  ```

### 5. Have fun, go outside, whatever

(TESTED ONLY ON DEBIAN BASED DISTROS, OTHER DISTRO SUPPORT MAY NOT WORK AS EXPECTED)
