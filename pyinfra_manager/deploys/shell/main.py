from dataclasses import dataclass
from enum import Enum

from deploys.shell.deployer.deploy import deploy
from deploys.shell.deployer.prepare_params import prepare_params
from vars import shell_vars


class ShellComplexity(Enum):
    Basic = 0
    Extended = 1


@dataclass
class Params:
    shell_complexity: ShellComplexity


def deploy_shell(params: Params) -> None:
    params = prepare_params(params.shell_complexity, shell_vars)
    deploy(params)
