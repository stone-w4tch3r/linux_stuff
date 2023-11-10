from dataclasses import dataclass

from pyinfra import host
from pyinfra.api.operation import OperationMeta
from pyinfra.facts import server as facts_server
from pyinfra.operations import apt, server, files, python

from deploys.shell.deployer.helpers import is_ohmyzsh_installed, assert_zsh_plugins_correct


@dataclass
class Params:
    packages: list[str]
    plugins_str: str
    home_path: str


def on_change(self: OperationMeta, func: callable) -> None:
    return func() if self.changed else None


OperationMeta.on_change = classmethod(on_change)


def deploy(params: Params) -> None:
    apt.update(cache_time=86400, _sudo=True)
    apt.packages(packages=params.packages, _sudo=True)

    if not is_ohmyzsh_installed(params.home_path):
        server.shell(commands=['sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'])

    server.user(user=host.get_fact(facts_server.User), shell="/usr/bin/zsh", _sudo=True)

    (files
     .line(path=f"{params.home_path}/.zshrc", replace=f"plugins=({params.plugins_str})", line="^plugins=.*", present=True)
     .on_change(python.call(function=assert_zsh_plugins_correct, home_path=params.home_path))
     )
