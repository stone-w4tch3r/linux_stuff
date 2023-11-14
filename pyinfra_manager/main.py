from deploys.shell.main import deploy_shell, ShellComplexity
from pyinfra import host

deploy_shell(ShellComplexity[host.data.shell_complexity])
