from enum import Enum

from pyinfra import host
from pyinfra.facts import files as facts_files
from pyinfra.facts import server as facts_server
from pyinfra.operations import apt, server, files, git, python

from deploys.shell.vars import shell_vars


class ShellComplexity(Enum):
    Basic = 0
    Extended = 1


def is_ohmyzsh_installed(home_path: str) -> bool:
    return host.get_fact(facts_files.Directory, f"{home_path}/.oh-my-zsh")


def deploy_shell(shell_complexity: ShellComplexity) -> None:
    packages = shell_vars.Packages
    plugins_str = " ".join(shell_vars.ZshPluginsBasic) \
        if shell_complexity == ShellComplexity.Basic \
        else " ".join(shell_vars.ZshPluginsBasic + shell_vars.ZshPluginsExtended)
    home_path = f"/home/{host.get_fact(facts_server.User)}"
    fonts_links = shell_vars.FontsLinks
    p10k_to_put = "deploys/shell/files/p10k_server.zsh" \
        if shell_complexity == ShellComplexity.Basic \
        else "deploys/shell/files/p10k_extended.zsh"
    powerlevel_block_content = [
        '# To customize prompt, run "p10k configure" or edit ~/.p10k.zsh.',
        '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh',
    ]
    aliases_block_content = shell_vars.AliasesBasic \
        if shell_complexity == ShellComplexity.Basic \
        else shell_vars.AliasesBasic + shell_vars.AliasesExtended

    apt.update(cache_time=86400, _sudo=True)
    apt.packages(packages=packages, _sudo=True)

    server.user(user=host.get_fact(facts_server.User), shell="/usr/bin/zsh", _sudo=True)

    if not is_ohmyzsh_installed(home_path):
        server.shell(commands=['sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'])

    git.repo(src="https://github.com/romkatv/powerlevel10k", dest=f"{home_path}/.oh-my-zsh/custom/themes/powerlevel10k", pull=False)
    files.put(src=p10k_to_put, dest=f"{home_path}/.p10k.zsh", mode="0644")

    files.line(path="/etc/environment", line="zic_case_insensitive=true", _sudo=True)

    files.line(path=f"{home_path}/.zshrc", replace=f"plugins=({plugins_str})", line="^plugins=.*")
    files.line(path=f"{home_path}/.zshrc", replace="ZSH_THEME=\"powerlevel10k/powerlevel10k\"", line="^ZSH_THEME=.*")

    # Ugly hack to bypass pyinfra two-step model. Wait for v3 to fix it
    python.call(
        function=lambda: files.block(
            path=f"{home_path}/.zshrc",
            content=powerlevel_block_content,
            marker="#### {mark} POWERLEVEL BLOCK ####",
        )
    )

    python.call(
        function=lambda: files.block(
            path=f"{home_path}/.zshrc",
            content=aliases_block_content,
            marker="#### {mark} ALIASES BLOCK ####",
        )
    )

    if shell_complexity == ShellComplexity.Extended:
        files.directory(path="/usr/share/fonts/truetype/", present=True, _sudo=True)
        for link in fonts_links:
            filename = link.split("/")[-1].replace("%20", " ")
            files.download(src=link, dest=f"/usr/share/fonts/truetype/{filename}", mode="0644", _sudo=True)
