import os

my_hosts = [
    (
        "primary.multipass",
        {
            "ssh_user": "ubuntu" if not os.path.isfile("keys/primary.multipass.ssh-key") else "lord",
            "ssh_password": "ubuntu" if not os.path.isfile("keys/primary.multipass.ssh-key") else "rnd_p4ss",
            "ssh_key": "keys/primary.multipass.ssh-key" if os.path.isfile("keys/primary.multipass.ssh-key") else None,
            "_use_sudo_password": "ubuntu" if not os.path.isfile("keys/primary.multipass.ssh-key") else "rnd_p4ss",
            "instance_complexity": "Normal",
            "ssh_key_path": "keys/primary.multipass.ssh-key",
            "server_user": "lord",
            "server_user_password": "rnd_p4ss",
        }
    ),
]
