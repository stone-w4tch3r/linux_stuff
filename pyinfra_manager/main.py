from deploys.server_upgrade.main import server_upgrade
from deploys.server_user.main import deploy_server_user
from deploys.zsh.main import deploy_zsh, ShellComplexity
from pyinfra import host
from pyinfra.operations import apt

from deploys.shell_tools.main import deploy_shell_tools

# server_upgrade()
# deploy_zsh()
# deploy_shell_tools()
deploy_server_user()
