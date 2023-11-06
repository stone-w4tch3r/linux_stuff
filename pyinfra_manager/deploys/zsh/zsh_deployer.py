from enum import Enum

from pyinfra import host
from pyinfra.facts import files as facts_files
from pyinfra.facts import server as facts_server
from pyinfra.operations import server, files, apt, python

from deploys.zsh.vars import zsh_vars


class ZshConfig(Enum):
    Basic = 0
    Extended = 1


def deploy_zsh(zsh_config: ZshConfig) -> None:
    apt.update(
        cache_time=86400,
        _sudo=True,
    )

    apt.packages(
        name="Install packages",
        packages=zsh_vars.Packages,
        _sudo=True,
    )

    # res = host.get_fact(
    #     FindInFile,
    #     path="/home/ubuntu/.zshrc",
    #     pattern='^.*plugins=.*.*$',
    #     interpolate_variables=False,
    # )

    if not host.get_fact(files.Directory, "~/.oh-my-zsh"):
        server.shell(
            name="Install oh-my-zsh",
            commands=[
                'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended',
            ],
        )

    server.user(
        name="Set zsh as default shell",
        user=host.get_fact(facts_server.User),
        shell="/usr/bin/zsh",
        _shell_executable="/bin/bash",
        _sudo=True,
    )

    plugins = " ".join(zsh_vars.ZshPluginsBasic) \
        if zsh_config == ZshConfig.Extended \
        else " ".join(zsh_vars.ZshPluginsBasic + zsh_vars.ZshPluginsExtended)

    files.line(
        name=f"Setup zsh plugins: ({plugins})",
        path="~/.zshrc",
        replace=f"plugins=({plugins})",
        line=r"plugins=.*",
        present=True,
    )

    found_plugin_lines = host.get_fact(facts_files.FindInFile, "~/.zshrc", "^plugins=.*")
    if found_plugin_lines is None:
        python.raise_exception(Exception, "Could not find line with 'plugins=' in ~/.zshrc")
    elif len(found_plugin_lines) != 1:
        python.raise_exception(Exception, f"Found {len(found_plugin_lines)} lines with 'plugins=' in ~/.zshrc")

