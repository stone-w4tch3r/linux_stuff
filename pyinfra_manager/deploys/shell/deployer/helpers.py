from pyinfra import host
from pyinfra.facts import files
from pyinfra.operations import python


def is_ohmyzsh_installed(home_path: str) -> bool:
    return host.get_fact(files.Directory, f"{home_path}/.oh-my-zsh")


def assert_zsh_plugins_correct(state, host, home_path: str) -> None:
    found_plugin_lines = host.get_fact(files.FindInFile, f"{home_path}/.zshrc", "^plugins=.*")
    if found_plugin_lines is None:
        python.raise_exception(Exception, f"Could not find line with 'plugins=' in {home_path}/.zshrc")
    elif len(found_plugin_lines) != 1:
        python.raise_exception(Exception, f"Found {len(found_plugin_lines)} lines with 'plugins=' in {home_path}/.zshrc")
