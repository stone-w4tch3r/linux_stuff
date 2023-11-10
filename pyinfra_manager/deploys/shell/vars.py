from dataclasses import dataclass


# region dataclasses
@dataclass
class ShellDeployVars:
    Packages: list[str]
    AliasesBasic: list[str]
    AliasesExtended: list[str]
    ZshPluginsBasic: list[str]
    ZshPluginsExtended: list[str]
    FontsLinks: list[str]
    DebianPlugins: list[str]
    UbuntuPlugins: list[str]


# endregion


shell_vars = ShellDeployVars(
    Packages=[
        "git",
        "zsh",
        "fzf",
        "zsh-syntax-highlighting",
        "zsh-autosuggestions",
        "thefuck",
        "fortune-mod",  # correct name for 'fortune'
    ],
    AliasesBasic=[
        "alias cat=ccat",
        "alias less=cless",
        "alias git_cp='echo -n commit message:  && read -r message && echo $message | git add . && git commit -m $message && git push'",
        "eval \"$(thefuck -a)\"",
    ],
    AliasesExtended=[
        "alias gitignore=gi",
        "alias codium='NODE_OPTIONS='' codium --enable-features=UseOzonePlatform --ozone-platform=wayland'",
        "alias multipass_recreate-primary='. ~/Projects/devops/scripts/multipass/recreate_multipass_primary.sh'",
    ],
    ZshPluginsBasic=[
        "git",
        "ag",
        "colored-man-pages",
        "colorize",
        "command-not-found",
        "docker",
        "docker-compose",
        "npm",
        "pip",
        "extract",  # archives
        "safe-paste",  # prevents pasted code from running
        "sudo",  # esc-esc
        "ufw",
        "zsh-interactive-cd",
    ],
    ZshPluginsExtended=[
        "dotnet",
        "adb",
        "ansible",
        "chucknorris",
        "emoji",  # get emoji as $emoji[name]
        "gh",
        "gitignore",
        "hitchhiker",
        "multipass",
    ],
    FontsLinks=[
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf",
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf",
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf",
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf",
    ],
    DebianPlugins=[
        "debian",
    ],
    UbuntuPlugins=[
        "ubuntu",
    ],
)
