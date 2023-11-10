from pyinfra import host
from pyinfra.api.operation import OperationMeta
from pyinfra.facts import files
from pyinfra.facts import server as facts_server
from pyinfra.operations import apt, server, files
from pyinfra.operations import python


def is_ohmyzsh_installed(home_path: str) -> bool:
    return host.get_fact(files.Directory, f"{home_path}/.oh-my-zsh")


def assert_zsh_plugins_correct(state, host, home_path: str) -> None:
    found_plugin_lines = host.get_fact(files.FindInFile, f"{home_path}/.zshrc", "^plugins=.*")
    if found_plugin_lines is None:
        python.raise_exception(Exception, f"Could not find line with 'plugins=' in {home_path}/.zshrc")
    elif len(found_plugin_lines) != 1:
        python.raise_exception(Exception, f"Found {len(found_plugin_lines)} lines with 'plugins=' in {home_path}/.zshrc")


def on_change(self: OperationMeta, func: callable) -> None:
    return func() if self.changed else None


OperationMeta.on_change = classmethod(on_change)


def deploy(packages: list[str], plugins_str: str, home_path: str) -> None:
    apt.update(cache_time=86400, _sudo=True)
    apt.packages(packages=packages, _sudo=True)

    if not is_ohmyzsh_installed(home_path):
        server.shell(commands=['sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'])

    server.user(user=host.get_fact(facts_server.User), shell="/usr/bin/zsh", _sudo=True)

    (files
     .line(path=f"{home_path}/.zshrc", replace=f"plugins=({plugins_str})", line="^plugins=.*", present=True)
     .on_change(python.call(function=assert_zsh_plugins_correct, home_path=home_path))
     )
