from enum import Enum

from pyinfra.operations import server

from deploys.zsh.vars import shell_vars


class ZshConfig(Enum):
    Basic = 0
    Extended = 1


def deploy_zsh(zsh_config: ZshConfig) -> None:
    server.packages(
        name="Install packages",
        packages=shell_vars.Packages,
        sudo=True,
    )

    server.shell(
        name="Install oh-my-zsh",
        commands=[
            'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended',
        ],
    )
