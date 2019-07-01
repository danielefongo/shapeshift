# shapeshift

shapeshift is an extremely customizable prompt inspired by [indresorhus/pure](https://github.com/sindresorhus/pure).

## Getting started

To use shapeshift on zsh you can either clone the project and source or use antigen

### Cloning and sourcing

From terminal:

```
cd <MYPATH>
git clone https://github.com/danielefongo/shapeshift
```

Then, source shapeshift on `.zshrc`:

```
source <MYPATH>/shapeshift/shapeshift.zsh
```

### Antigen

Insert in `.zshrc`:

```
antigen bundle danielefongo/shapeshift
```

## Customization

Every element showed on the prompt can be customized by changing properties. You can do it by adding an assignment after the sourcing or the `antigen apply` command. The default properties that can be changed are the following:

```
SHAPESHIFT_PROMPT_LEFT_ELEMENTS=(last_command_elapsed_seconds prompt_dir prompt_arrow)
SHAPESHIFT_PROMPT_RIGHT_ELEMENTS=(async_git_position async_git_merging async_git_diffs async_git_branch)

SHAPESHIFT_LAST_COMMAND_ELAPSED_SECONDS_COLOR="yellow"
SHAPESHIFT_LAST_COMMAND_ELAPSED_SECONDS_BOLD=true

SHAPESHIFT_GIT_BRANCH_COLOR="white"
SHAPESHIFT_GIT_BRANCH_BOLD=true

SHAPESHIFT_GIT_AHEAD="+NUM"
SHAPESHIFT_GIT_AHEAD_COLOR="cyan"
SHAPESHIFT_GIT_AHEAD_BOLD=true

SHAPESHIFT_GIT_BEHIND="-NUM"
SHAPESHIFT_GIT_BEHIND_COLOR="cyan"
SHAPESHIFT_GIT_BEHIND_BOLD=true

SHAPESHIFT_GIT_DETATCHED="!"
SHAPESHIFT_GIT_DETATCHED_COLOR="red"
SHAPESHIFT_GIT_DETATCHED_BOLD=true

SHAPESHIFT_GIT_MERGING="x"
SHAPESHIFT_GIT_MERGING_COLOR="cyan"
SHAPESHIFT_GIT_MERGING_BOLD=true

SHAPESHIFT_GIT_DIFF_SYMBOL="-"
SHAPESHIFT_GIT_UNTRACKED_COLOR="red"
SHAPESHIFT_GIT_UNTRACKED_BOLD=true
SHAPESHIFT_GIT_MODIFIED_COLOR="blue"
SHAPESHIFT_GIT_MODIFIED_BOLD=true
SHAPESHIFT_GIT_STAGED_COLOR="green"
SHAPESHIFT_GIT_STAGED_BOLD=true

SHAPESHIFT_ARROW_OK_CHAR="❯"
SHAPESHIFT_ARROW_OK_COLOR="green"
SHAPESHIFT_ARROW_OK_CHAR_BOLD=true
SHAPESHIFT_ARROW_KO_CHAR="❯"
SHAPESHIFT_ARROW_KO_COLOR="red"
SHAPESHIFT_ARROW_KO_CHAR_BOLD=true

SHAPESHIFT_DIR_LENGTH=3
SHAPESHIFT_TRUNCATED_DIR_COLOR="blue"
SHAPESHIFT_TRUNCATED_DIR_BOLD=false
SHAPESHIFT_LAST_FOLDER_DIR_COLOR="blue"
SHAPESHIFT_LAST_FOLDER_DIR_BOLD=true
```

### Segment functions

As you can see, `PROMPT_LEFT_ELEMENTS` and `PROMPT_RIGHT_ELEMENTS` contain a list of elements: every element represents a `segment function` that will be evaluated to print data on the prompt. A PROMPT_LEFT_ELEMENTS segment function can print multiple lines using two or more `echo` (or similar command).

Functions starting with `async` are evaluated asynchronously so the prompt is not freezed while they are running; after the evaluation, the prompt will be refreshed automatically.

You can define custom segments functions and add them in one of the array showed above:

```zsh
# on .zshrc

# loading stuff...

function async_sleeping_function() {
  sleep 10 && echo "i was sleeping"
}

PROMPT_LEFT_ELEMENTS=(async_sleeping_function prompt_dir prompt_arrow)
```

### Colorize text

You can use the `colorize` function inside a segment function to echo a colorized text. The signature is the following:

```
colorize <text> <color> <bold>
```

You can also use `colorizeFromStatus` function inside a segment function to echo a colorized text based on the status of the last command. The signature is the following:

```
colorizeFromStatus <ok-text> <ok-color> <ok-bold> <ko-text> <ko-color> <ko-bold>
```

Where bold can be `true` or `false`.

### Themes

You can define your own custom theme by creating a repo on github with a file named `shapeshift.theme` in the root and containing all the customizations needed (see this [theme](https://github.com/danielefongo/fish-shapeshift) for example).

You can then import your theme by using the command `shapeshift-import <user>/<repo>`.

With the command `shapeshift-set [<user>/<repo>]` you set the theme as default. If the parameter is not passed, shapeshift will set the default theme. Remember that you can press TAB to show all the installed themes. If you are using antigen and you have problem with the auto-completion, just run `rm -rf ~/.zcompdump && antigen reset` and try again with a new shell.
