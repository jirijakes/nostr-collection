export TZ := "UTC0"

@_default:
    just --list

# Display projects in a tree
@tree:
    tree -L 3 -d -C

# Update all projects' repos
[private]
update-repos:
    git submodule update --remote --merge

# Update README.org
[private]
update-readme:
    #!/usr/bin/env bash
    cp .readme.head README.org
    just infotable >> README.org

# Perform update of the content
update: update-repos update-readme

# Displays Emacs-formatted table with information about projects
infotable:
    #!/usr/bin/env bash
    echo "| Name | Type | Language | Source | Last commit |"
    echo "|------+------+----------+--------+-------------|"
    git -P submodule -q foreach just infotablerow | sort

# Display info for each project
[no-cd]
[private]
infotablerow:
    #!/usr/bin/env bash
    set -euo pipefail
    printf "| %s | %s | %s | %s | %s |\n" $(just name) $(just type) $(just language) "[[$(just source)][gh]]" "$(just latest)"

# Display latest commits in a repo
[no-cd]
[private]
@latest:
    git show -s --format='%s (%ad)' --date=format-local:'%Y-%m-%d %H:%M' 

# Display director name of a repo
[no-cd]
[private]
@name:
    basename `git rev-parse --show-toplevel`

# Display in which language the repo code is written
[no-cd]
[private]
language:
    #!/usr/bin/env bash
    if [[ -f "Cargo.toml" || -f "build.rs" ]]; then echo "Rust"
    elif [[ -f "tsconfig.json" ]]; then echo "TypeScript"
    elif [[ -f "Project.toml" ]]; then echo "Julia"
    elif [[ -f "Package.swift" ]]; then echo "Swift"
    elif compgen -G "*.cabal" > /dev/null; then echo "Haskell"
    elif [[ -f "stack.yaml" ]]; then echo "Haskell"
    elif grep -q -i kotlin build.gradle; then echo "Kotlin"
    else echo "Unknown"
    fi

# Display origin URL of the repo
[no-cd]
[private]
@source:
    git config --get remote.origin.url

[no-cd]
[private]
type:
    #!/usr/bin/env bash
    cd ../..
    grandma=$(basename `pwd`)
    if [[ $grandma == "clients" ]]; then echo "client"
    elif [[ $grandma == "sdk" ]]; then echo "sdk"
    elif [[ $grandma == "relays" ]]; then echo "relay"
    fi
