from dataclasses import dataclass


# region dataclasses
@dataclass
class ShellDeployVars:
    Packages: list[str]
    AliasesBasic: list[str]
    AliasesExtended: list[str]
    MiscLinesAtEnd: list[str]
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
        "fzf",  # for zsh-interactive-cd
        "chroma",  # for ccat/cless
        "micro",  # editor
        "zsh-syntax-highlighting",
        "zsh-autosuggestions",
        "thefuck",  # say 'fuck' and the error is fixed!
        "fortune-mod",  # correct name for 'fortune'
    ],
    AliasesBasic=[
        "alias cat=ccat",
        "alias less=cless",
        'alias git_cp=echo -n commit message:  && read -r message && echo \$message | git add . && git commit -m \$message && git push',  # noqa: W605
        'eval $(thefuck -a)',
    ],
    AliasesExtended=[
        "alias gitignore=gi",
        "alias codium='NODE_OPTIONS='' codium --enable-features=UseOzonePlatform --ozone-platform=wayland'",  # wayland support
        "alias multipass_recreate-primary='. ~/Projects/devops/scripts/multipass/recreate_multipass_primary.sh'",
    ],
    MiscLinesAtEnd=[
        '# To customize prompt, run "p10k configure" or edit ~/.p10k.zsh.',
        '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh',
        '# FOR SYNTAX-HIGHLIGHTING TO WORK, THIS LINE MUST LAST',
        'source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'
    ],
    ZshPluginsBasic=[
        "git",
        "ag",  # search
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
