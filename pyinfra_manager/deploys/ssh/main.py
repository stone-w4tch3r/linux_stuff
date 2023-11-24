import subprocess

from pyinfra.operations import apt, ssh, server, files
from pyinfra import host


def run_locally(cmd: str, ignore_errs: bool = False) -> None:
    subprocess.run(cmd, shell=True, check=not ignore_errs)


def deploy_ssh() -> None:
    apt.packages(packages=["openssh-server"], _sudo=True)

    overwrite = True
    hostname = host.name
    ssh_key = host.data.ssh_key_path
    server_user = host.data.server_user
    server_user_password = host.data.server_user_password

    ssh.keyscan(hostname=hostname, force=True)

    overwrite_existing_key = 'y' if overwrite else 'n'
    # -q: quiet, -N: passphrase, -f: filename, <<< X: interactive input (overwrite?)
    run_locally(f"ssh-keygen -t rsa -f {ssh_key} -q -N '' < /dev/null", ignore_errs=True)

    server.user_authorized_keys(user=server_user, public_keys=[ssh_key + ".pub"], _sudo=True)

    files.line(path="/etc/ssh/sshd_config", replace=r".*PasswordAuthentication.*", line="PasswordAuthentication yes", _sudo=True)
    files.line(path="/etc/ssh/sshd_config", replace=r".*PermitRootLogin.*", line="PermitRootLogin yes", _sudo=True)

    server.service(service="sshd", restarted=True, _sudo=True)

    # update connection data
    host.data.override_datas["ssh_key"] = ssh_key
    if host.data.ssh_user != server_user:
        host.data.override_datas["ssh_user"] = server_user
    if host.data.ssh_password != server_user_password:
        host.data.override_datas["ssh_password"] = server_user_password
