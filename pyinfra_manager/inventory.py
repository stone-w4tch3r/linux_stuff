import os

my_hosts = [
    (
        "primary.multipass",
        {
            "ssh_user": "ubuntu",
            "ssh_password": "ubuntu",
            "ssh_key": "keys/primary.multipass.ssh-key" if os.path.isfile("keys/primary.multipass.ssh-key") else None,
            "_use_sudo_password": "ubuntu",
            "shell_complexity": "Basic",
            "server_user": "lord",
            "server_user_password": "r4ndmP4ssw0rd",
        }
    ),
]
