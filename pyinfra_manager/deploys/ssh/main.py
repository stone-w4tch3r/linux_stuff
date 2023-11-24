import os
import subprocess

from pyinfra.operations import apt, ssh, server, files
from pyinfra import host


def run_locally(cmd: str, ignore_errs: bool = False) -> None:
    subprocess.run(cmd, shell=True, check=not ignore_errs)


def deploy_ssh() -> None:
    apt.packages(packages=["openssh-server"], _sudo=True)

    local_known_hosts = f"/home/{os.getlogin()}/.ssh/known_hosts"
    overwrite = host.data.get("overwrite_ssh") is True
    hostname = host.name
    ssh_key = host.data.ssh_key_path
    server_user = host.data.server_user
    server_user_password = host.data.server_user_password

    if overwrite or open(local_known_hosts).read().find(hostname) == -1:
        run_locally(f"ssh-keygen -f {local_known_hosts} -R primary.multipass", ignore_errs=True)
        run_locally(f"ssh-keyscan -H {hostname} >> {local_known_hosts}", ignore_errs=False)

    overwrite_existing_key = 'y' if overwrite else 'n'
    # -q: quiet, -N: passphrase, -f: filename
    run_locally(f"echo {overwrite_existing_key} | ssh-keygen -t rsa -f {ssh_key} -q -N ''", ignore_errs=True)
    run_locally(f"chmod 600 {ssh_key}", ignore_errs=True)

    server.user_authorized_keys(user=server_user, public_keys=[ssh_key + ".pub"], _sudo=True)

    files.line(path="/etc/ssh/sshd_config", replace="PasswordAuthentication no", line="PasswordAuthentication yes", _sudo=True)
    files.line(path="/etc/ssh/sshd_config", replace="PermitRootLogin no", line="PermitRootLogin yes", _sudo=True)

    # server.service(service="sshd", restarted=True, _sudo=True)
    server.shell(name="Restart sshd", commands="sudo systemctl restart sshd", _sudo=True)

    # update connection data
    host.data.override_datas["ssh_key"] = ssh_key
    if host.data.ssh_user != server_user:
        host.data.override_datas["ssh_user"] = server_user
    if host.data.ssh_password != server_user_password:
        host.data.override_datas["ssh_password"] = server_user_password
