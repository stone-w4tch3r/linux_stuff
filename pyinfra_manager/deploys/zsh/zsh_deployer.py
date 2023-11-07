from enum import Enum

from pyinfra import host
from pyinfra.facts import files as facts_files
from pyinfra.facts import server as facts_server
from pyinfra.operations import server, files, apt, python

from deploys.zsh.vars import zsh_vars


class ZshConfig(Enum):
    Basic = 0
    Extended = 1


def assert_zsh_plugins_correct(state, host, _home_dir: str) -> None:
    found_plugin_lines = host.get_fact(facts_files.FindInFile, f"{_home_dir}/.zshrc", "^plugins=.*")
    if found_plugin_lines is None:
        python.raise_exception(Exception, f"Could not find line with 'plugins=' in {_home_dir}/.zshrc")
    elif len(found_plugin_lines) != 1:
        python.raise_exception(Exception, f"Found {len(found_plugin_lines)} lines with 'plugins=' in {_home_dir}/.zshrc")


def deploy_zsh(zsh_config: ZshConfig) -> None:
    _home_dir = f"/home/{host.get_fact(facts_server.User)}"

    apt.update(
        cache_time=86400,
        _sudo=True,
    )

    apt.packages(
        name="Install packages",
        packages=zsh_vars.Packages,
        _sudo=True,
    )

    if not host.get_fact(files.Directory, f"{_home_dir}/.oh-my-zsh"):
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
    plugins_editing_result = files.line(
        name=f"Setup zsh plugins: ({plugins})",
        path=f"{_home_dir}/.zshrc",
        replace=f"plugins=({plugins})",
        line="^plugins=.*",
        present=True,
    )

    if plugins_editing_result.changed:
        python.call(
            name="Assert zsh plugins are correct",
            function=assert_zsh_plugins_correct,
            _home_dir=_home_dir,
        )
