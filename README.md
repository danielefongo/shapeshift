# shapeshift

![CI](https://github.com/danielefongo/shapeshift/workflows/CI/badge.svg)

shapeshift is an extremely customizable asynchronous prompt inspired by [sindresorhus/pure](https://github.com/sindresorhus/pure).

<p align="center">
  <a href="https://www.youtube.com/watch?v=HFoeg4JSTPo">
    <img alt="shapeshift prompt" src="https://media.giphy.com/media/eIrzPwzRjpfwES6CKD/source.gif" width="600">
  </a>
</p>

## Getting started

To use shapeshift on zsh you can either clone the project and source or use antigen.

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

Every element showed on the prompt can be easily customized by overriding properties. You can do it in different ways:

- by adding assignments after the sourcing or the `antigen apply` command.
- by creating your own theme with all the customized properties.

See below for more details.

### Segment functions

```
SHAPESHIFT_PROMPT_LEFT_ELEMENTS=(last_command_elapsed_time prompt_dir prompt_arrow)
SHAPESHIFT_PROMPT_RIGHT_ELEMENTS=(async_git_position async_git_merging async_git_diffs async_git_branch)
SHAPESHIFT_RESET_ASYNC_OUTPUTS_BEFORE_UPDATING=false
```

As you can see, `SHAPESHIFT_PROMPT_LEFT_ELEMENTS` and `SHAPESHIFT_PROMPT_RIGHT_ELEMENTS` contain a list of elements: every element represents a `segment function` that will be evaluated to print data on the prompt. A `PROMPT_LEFT_ELEMENTS` segment function can print multiple lines using two or more `echo` (or similar command).

Custom segment functions can be created and added in one of the array showed above. If you add that segment function with `async_` prefix, that function will be run asynchronously so the prompt is not freezed while it is running; after the evaluation, the prompt will be refreshed automatically. An example of custom segment function:

```zsh
function sleeping_function() {
  sleep 10 && echo "i was sleeping"
}

PROMPT_LEFT_ELEMENTS=(async_sleeping_function prompt_dir prompt_arrow)
```

If the reset of the async segment function's output after each command is annoying you, just change `SHAPESHIFT_RESET_ASYNC_OUTPUTS_BEFORE_UPDATING` to `true`!

#### Colorize

You can use the `colorize` function inside a segment function to echo a colorized text. The signature is the following:

```
colorize <text> <color> <bold>
```

You can also use `colorize_from_status` function inside a segment function to echo a colorized text based on the status of the last command. The signature is the following:

```
colorize_from_status <ok-text> <ok-color> <ok-bold> <ko-text> <ko-color> <ko-bold>
```

Where bold can be `true` or `false`.

#### Git folder

You can check if you are on git folder by using the `SHAPESHIFT_IS_GIT_REPO` variable to speed up computations.

### Default segment functions properties

Default segment functions have some useful properties:

#### last_command_elapsed_time

```
SHAPESHIFT_LAST_COMMAND_ELAPSED_TIME_COLOR="yellow"
SHAPESHIFT_LAST_COMMAND_ELAPSED_TIME_BOLD=true
```

#### git_branch

```
SHAPESHIFT_GIT_BRANCH_COLOR="white"
SHAPESHIFT_GIT_BRANCH_BOLD=true
```

#### git_position

```
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
```

#### git_diffs

```
SHAPESHIFT_GIT_DIFF_SYMBOL="-"
SHAPESHIFT_GIT_UNTRACKED_COLOR="red"
SHAPESHIFT_GIT_UNTRACKED_BOLD=true
SHAPESHIFT_GIT_MODIFIED_COLOR="blue"
SHAPESHIFT_GIT_MODIFIED_BOLD=true
SHAPESHIFT_GIT_STAGED_COLOR="green"
SHAPESHIFT_GIT_STAGED_BOLD=true
```

#### prompt_dir

```
SHAPESHIFT_DIR_LENGTH=3
SHAPESHIFT_TRUNCATED_DIR_COLOR="blue"
SHAPESHIFT_TRUNCATED_DIR_BOLD=false
SHAPESHIFT_LAST_FOLDER_DIR_COLOR="blue"
SHAPESHIFT_LAST_FOLDER_DIR_BOLD=true
```

#### prompt_arrow

```
SHAPESHIFT_ARROW_OK_CHAR="❯"
SHAPESHIFT_ARROW_OK_COLOR="green"
SHAPESHIFT_ARROW_OK_CHAR_BOLD=true
SHAPESHIFT_ARROW_KO_CHAR="❯"
SHAPESHIFT_ARROW_KO_COLOR="red"
SHAPESHIFT_ARROW_KO_CHAR_BOLD=true
```

### Prompt newline

```
SHAPESHIFT_NEWLINE_AFTER_COMMAND=true
```

After each command shapeshift will render a newline. You can remove that by disabling this flag.

### Colorized ls

```
SHAPESHIFT_LS_COLORS=(boldcyan magenta green default red grey grey)
SHAPESHIFT_LS_COLORS_ENABLED=true
```

Shapeshift comes with colorized `ls`. To customize the showed colors you can set the `SHAPESHIFT_LS_COLORS` list to define colors for:

- 1° element: directory
- 2° element: symbolic link
- 3° element: socket
- 4° element: pipe
- 5° element: executable
- 6° element: block special
- 7° element: character special

The possible colors are the following:

- default
- black, boldblack
- red, boldred
- green, boldgreen
- yellow, boldyellow
- blue, boldblue
- magenta, boldmagenta
- cyan, boldcyan
- grey, boldgrey

Any wrong color will be replaced with the default one.

### Pre-prompt

```
SHAPESHIFT_PRECMD="source myfile"
```

If set, this zsh code will be run before the command.

### Themes

You can define your own custom theme by creating a repo on github with a file named `shapeshift.theme` in the root and containing the customizations needed (go [here](https://github.com/shapeshift-zsh) to check out some themes).

#### Set a theme

With the command `shape-shift [<user>/<repo>]` you can set the provided theme as default. If the theme is not installed, shapeshift will download it for you automatically. When the parameter is not passed, shapeshift will set the default theme. For uniquely named installed themes, you can just insert the repo without the user.

Remember that you can press TAB to show all the installed themes. If you are using antigen and you have problem with the auto-completion, just run `rm -rf ~/.zcompdump && antigen reset` and try again with a new shell.

##### Update installed themes

To update themes you should run `shape-reshape`.

#### Delete a theme

With the command `shape-destroy <user>/<repo>` or `shape-shift <uniquely-named-repo>` you can remove a installed theme.
