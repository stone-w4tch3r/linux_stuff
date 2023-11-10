from pyinfra import host
from pyinfra.facts import server as facts_server
from deploys.shell.main import ShellComplexity
from deploys.shell.deployer.deploy import Params
from deploys.shell.vars import ShellDeployVars


def prepare_params(shell_complexity: ShellComplexity, shell_vars: ShellDeployVars) -> Params:
    home_path = f"/home/{host.get_fact(facts_server.User)}"

    plugins = " ".join(shell_vars.ZshPluginsBasic) \
        if shell_complexity == ShellComplexity.Extended \
        else " ".join(shell_vars.ZshPluginsBasic + shell_vars.ZshPluginsExtended)

    return Params(
        packages=shell_vars.Packages,
        plugins_str=plugins,
        home_path=home_path,
    )