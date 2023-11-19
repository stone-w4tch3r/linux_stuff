from deploys.server_upgrade.main import server_upgrade
from deploys.shell.main import deploy_shell, ShellComplexity
from pyinfra import host
from pyinfra.operations import apt

server_upgrade()
deploy_shell(ShellComplexity[host.data.shell_complexity])
apt.packages(packages=["neofetch"], _sudo=True)
