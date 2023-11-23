import re

from pyinfra.operations import apt, server, python
from pyinfra.facts import apt as facts_apt
from pyinfra import host

from inventory_types import ShellComplexity


def is_source_added(source_url_regex: str) -> bool:
    source_urls = [src["url"] for src in host.get_fact(facts_apt.AptSources)]
    return any([re.match(source_url_regex, url) for url in source_urls])


def deploy_shell_tools():
    shell_complexity = ShellComplexity[host.data.shell_complexity]
    packages_from_ubuntu_basic = [
        "tree",
        "mc",
        "neofetch",
        "ncdu",
        "micro",
        "net-tools",
        "silversearcher-ag",
    ]
    packages_from_ubuntu_extended = [
        "python3-venv",
        "python3-pip",
    ]
    packages_from_repos_basic = [
        "broot",
    ]
    packages_from_repos_extended = [
        "gh",
    ]
    packages = packages_from_ubuntu_basic + packages_from_repos_basic \
        if shell_complexity == ShellComplexity.Basic \
        else packages_from_ubuntu_basic + packages_from_repos_basic + packages_from_ubuntu_extended + packages_from_repos_extended

    if "gh" in packages and not is_source_added(r".*cli\.github\.com.*"):
        server.shell(
            name="Shell: Add gh source to apt",
            commands=
            """
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
            && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
            && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
                https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            """,
            _sudo=True
        )

    if "broot" in packages and not is_source_added(r".*packages\.azlux\.fr.*"):
        server.shell(
            name="Shell: Add broot source to apt",
            commands=
            """
            echo "deb [signed-by=/usr/share/keyrings/azlux-archive-keyring.gpg] http://packages.azlux.fr/debian/ stable main" \
                | sudo tee /etc/apt/sources.list.d/azlux.list
            sudo wget -O /usr/share/keyrings/azlux-archive-keyring.gpg  https://azlux.fr/repo.gpg
            """,
            _sudo=True
        )

    apt.update(_sudo=True)
    apt.packages(packages=packages, _sudo=True)
