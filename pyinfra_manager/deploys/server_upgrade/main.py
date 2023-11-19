from pyinfra.operations import apt, server


def server_upgrade():
    apt.update(cache_time=86400, _sudo=True)
    apt.upgrade(auto_remove=True, _sudo=True)
    apt.dist_upgrade(_sudo=True)
    server.reboot(_sudo=True)


# main
# server_upgrade()
