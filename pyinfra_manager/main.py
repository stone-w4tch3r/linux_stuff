from pyinfra.facts import files

from deploys.server_upgrade.server_upgrade import server_upgrade
from deploys.server_user.server_user import deploy_server_user
from deploys.shell_aliases.shell_aliases import deploy_aliases
from deploys.ssh.ssh import deploy_ssh
from deploys.zsh.zsh import deploy_zsh, ShellComplexity
from pyinfra import host
from pyinfra.operations import apt

from deploys.shell_tools.shell_tools import deploy_shell_tools

# server_upgrade()
deploy_server_user()
# deploy_zsh()
# deploy_shell_tools()
# deploy_aliases()
deploy_ssh()
