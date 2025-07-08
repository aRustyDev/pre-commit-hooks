# Readme

| Lang       | Linting | Formatting | Testing | Building | Publishing | Documentation |
|------------|---------|------------|---------|----------|------------|---------------|
| Changelog  |         |            |         |          |            |               |
| Commits    |         |            |         |          |            |               |
| TODOs      |         |            |         |          |            |               |
| Obj-C      |         |            |         |          |            |               |
| Swift      |         |            |         |          |            |               |
| C          |         |            |         |          |            |               |
| C#         |         |            |         |          |            |               |
| C++        |         |            |         |          |            |               |
| Carbon     |         |            |         |          |            |               |
| Rust       |         |            |         |          |            |               |
| Golang     |         |            |         |          |            |               |
| SQL        |         |            |         |          |            |               |
| YAML       |         |            |         |          |            |               |
| Make       |         |            |         |          |            |               |
| TOML       |         |            |         |          |            |               |
| JSON       |         |            |         |          |            |               |
| HTML       |         |            |         |          |            |               |
| HTMX       |         |            |         |          |            |               |
| CSS        |         |            |         |          |            |               |
| SCSS       |         |            |         |          |            |               |
| JavaScript |         |            |         |          |            |               |
| TypeScript |         |            |         |          |            |               |
| Protobuf   |         |            |         |          |            |               |
| Python2    |         |            |         |          |            |               |
| Python3    |         |            |         |          |            |               |
| Terraform  |         |            |         |          |            |               |
| Lua        |         |            |         |          |            |               |
| Images     |         |            |         |          |            |               |
| Packer     |         |            |         |          |            |               |
| Vault      |         |            |         |          |            |               |
| Vagrant    |         |            |         |          |            |               |
| Ansible    |         |            |         |          |            |               |
| GHAction   |         |            |         |          |            |               |
| GitLeaks   |         |            |         |          |            |               |
| GGShields  |         |            |         |          |            |               |
| Talisman   |         |            |         |          |            |               |
| TruffleHog |         |            |         |          |            |               |

## Pre-Push

Before pushing something to a remote repository one should check if all tests are passing, and fix them if they don’t.

```bash
#!/bin/sh

go test ./...
```

## Pre-commit

Check for syntax error at each commit is a good way of using this hook. As a static code analysis tool, I prefer to use https://golangci-lint.run/ that already includes a big number of different linters.

```bash
#!/bin/sh

golangci-lint run --tests=0 ./...
```

## Prepare-commit-msg

The nice naming convention for git branches gives you an ability to understand with which task all work in a concrete branch relates to a task at task tracker, e.g. SP-312 about ‘new feature’ is not only for task slug but for branch name also. Part of this convention also suggests that each commit message done this 'new feature' is prefixed with branch name [SP-312] done this 'new feature'. That gives you an ability to understand after branches are removed to wich task this very commit in commit history relates to. To automate prefixing each commit message with the branch name I use the following

```bash
#!/bin/sh

# set -- $GIT_PARAMS

BRANCH_NAME=$(git symbolic-ref --short HEAD)

BRANCH_IN_COMMIT=0
if [ -f $1 ]; then
    BRANCH_IN_COMMIT=$(grep -c "\[$BRANCH_NAME\]" $1)
fi

if [ -n "$BRANCH_NAME" ] && ! [[ $BRANCH_IN_COMMIT -ge 1 ]]; then
  if [ -f $1 ]; then
    BRANCH_NAME="${BRANCH_NAME/\//\/}"
    sed -i.bak -e "1s@^@[$BRANCH_NAME] @" $1
  else
    echo "[$BRANCH_NAME] " > "$1"
  fi
fi

exit 0
```
