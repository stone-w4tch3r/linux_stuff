from pyinfra import host
from pyinfra.operations import files, python
from pyinfra.facts import server as facts_server

from deploys.shell_aliases.vars import aliases_vars
from inventory_types import ShellComplexity


def deploy_aliases() -> None:
    shell_complexity = ShellComplexity[host.data.shell_complexity]
    home_path = f"/home/{host.get_fact(facts_server.User)}"
    aliases_block_content = aliases_vars.AliasesNormal \
        if shell_complexity == ShellComplexity.Normal \
        else aliases_vars.AliasesNormal + aliases_vars.AliasesExtended

    python.call(
        function=lambda: files.block(
            path=f"{home_path}/.zshrc",
            content=aliases_block_content,
            marker="#### {mark} ALIASES BLOCK ####",
            try_prevent_shell_expansion=True,
        )
    )
