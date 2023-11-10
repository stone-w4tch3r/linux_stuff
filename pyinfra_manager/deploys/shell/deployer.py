from pyinfra import host
from pyinfra.api.operation import OperationMeta
from pyinfra.facts import files
from pyinfra.facts import server as facts_server
from pyinfra.operations import apt, server, files


def is_ohmyzsh_installed(home_path: str) -> bool:
    return host.get_fact(files.Directory, f"{home_path}/.oh-my-zsh")


def are_fonts_installed() -> bool:
    return host.get_fact(files.File, "/usr/share/fonts/truetype/MesloLGS.*")


def on_change(operation: OperationMeta, func: callable) -> OperationMeta:
    if operation.changed:
        func()
    return operation


OperationMeta.on_change = classmethod(on_change)


def deploy(packages: list[str], plugins_str: str, home_path: str) -> None:
    apt.update(cache_time=86400, _sudo=True)
    apt.packages(packages=packages, _sudo=True)

    if not is_ohmyzsh_installed(home_path):
        server.shell(commands=['sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'])

    server.user(user=host.get_fact(facts_server.User), shell="/usr/bin/zsh", _sudo=True)

    files.line(path=f"{home_path}/.zshrc", replace=f"plugins=({plugins_str})", line="^plugins=.*")

    files.line(path="/etc/environment", line="zic_case_insensitive=true", _sudo=True)

    if not are_fonts_installed():
        pass
