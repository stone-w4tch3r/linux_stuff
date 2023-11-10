from enum import Enum

from pyinfra import host
from pyinfra.facts import server

from deploys.shell.deployer import deploy
from vars import shell_vars


class ShellComplexity(Enum):
    Basic = 0
    Extended = 1


def prepare_params(shell_complexity: ShellComplexity) -> tuple[list[str], str, str]:
    return (
        shell_vars.Packages,
        (" ".join(shell_vars.ZshPluginsBasic)
         if shell_complexity == ShellComplexity.Extended
         else " ".join(shell_vars.ZshPluginsBasic + shell_vars.ZshPluginsExtended)),
        f"/home/{host.get_fact(server.User)}",
    )


def deploy_shell(shell_complexity: ShellComplexity) -> None:
    params = prepare_params(shell_complexity)
    deploy(*params)
