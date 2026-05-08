# FOSS Virtualization on Linux – Quick Notes

## 1. Alternatives to VirtualBox

| Solution                       | UX style                        | Key strengths                                                                                                         | Weaknesses / gotchas      |
| ------------------------------ | ------------------------------- | --------------------------------------------------------------------------------------------------------------------- | ------------------------- |
| **Virt‑Manager + libvirt/KVM** | Classic desktop GUI (like VBox) | Mature, full feature set (TPM, snapshots, PCI/GPU passthrough), best performance, shares backend with all other tools | UI a bit denser           |
| **GNOME Boxes**                | Minimal wizard                  | One‑click ISOs, auto‑config, Flatpak                                                                                  | Limited knobs, USB quirks |
| **Cockpit Machines**           | Web UI                          | Remote-friendly, metrics graphs, snapshots                                                                            | Requires Cockpit service  |
| **Quickemu + QuickGUI**        | Simple list                     | 1 000+ pre‑tuned configs, macOS guest scripts                                                                         | Less customisation        |
| **Virt‑Lightning**             | CLI YAML                        | Very fast throw‑away labs, integrates Ansible                                                                         | Not a GUI                 |
| **Vagrant (libvirt provider)** | IaC DSL                         | Reuse existing Vagrantfiles, large box ecosystem                                                                      | Needs plugin              |

## 2. Installation cheat‑sheet

### Fedora **mutable** (Workstation, Server)

```bash
# Backend
sudo dnf install @virtualization virtio-win

# Front‑ends
sudo dnf install virt-manager gnome-boxes cockpit cockpit-machines quickemu virt-lightning
sudo systemctl enable --now libvirtd.socket cockpit.socket
sudo usermod -aG libvirt $USER && newgrp libvirt
```

### Fedora **immutable** (Silverblue/Kinoite/Onyx/Sericea)

```bash
# Layer packages & reboot
sudo rpm-ostree install \
  qemu-kvm libvirt-daemon-kvm libvirt-daemon-config-network \
  virt-install virt-manager virt-viewer \
  libguestfs-tools guestfs-browser virt-top \
  quickemu cockpit cockpit-machines

# GUI via Flatpak
flatpak install flathub org.gnome.Boxes \
                       org.virt_manager.virt-manager \
                       org.virt_manager.virt-manager.Extension.Qemu

# Finally
```

### Ubuntu / Debian

```bash
sudo apt install qemu-kvm libvirt-daemon-system virt-manager \
                 gnome-boxes cockpit cockpit-machines quickemu quickgui \
                 virt-lightning vagrant libvirt-daemon-driver-qemu

sudo adduser $USER libvirt
sudo systemctl enable --now libvirtd
```

> **Secure Boot:** KVM modules are in‑tree & signed. No dkms hoops.

## 3. Windows & macOS guests

* **Windows 10/11:** use UEFI (OVMF) + `virtio-win.iso`; add a virtual TPM 2.0 for Win 11.
* **macOS:** Quickemu/OSX‑KVM script; experimental, software rendering, license only valid on Apple hardware.

## 4. Vagrant workflow (libvirt provider)

```bash
# Fedora (mutable or immutable)
sudo dnf install vagrant vagrant-libvirt       # or rpm‑ostree install …

# Ubuntu / Debian
sudo apt install vagrant ruby-libvirt
vagrant plugin install vagrant-libvirt vagrant-mutate

# Vagrantfile snippet
Vagrant.configure("2") do |config|
  config.vm.box = "generic/fedora40"        # any *libvirt* box
  config.vm.provider :libvirt do |lib|
    lib.memory = 4096
  end
end

vagrant up --provider=libvirt
```

* Convert legacy boxes: `vagrant mutate my.box libvirt`.
* Runs fine on host; inside Toolbox/Distrobox for NAT‑only labs.

## 5. Raw CLI & automation

| Tool               | Quick example                                                                                     |
| ------------------ | ------------------------------------------------------------------------------------------------- |
| **virt-install**   | `virt-install --name dev --memory 4096 --disk size=40 --cdrom ./fedora.iso --os-variant fedora40` |
| **virt-xml**       | Modify an existing VM: `virt-xml dev --edit --memory 8192`                                        |
| **virt-lightning** | `vl up fedora-40` (reads `config.yml`)                                                            |
| **quickemu**       | `quickemu --vm ubuntu-24.04.conf`                                                                 |
| **Terraform**      | `provider "libvirt" { uri = "qemu:///system" }`                                                   |
| **Ansible**        | `- name: create vm\n  community.libvirt.virt:`                                                    |

---

**Tip:** All front‑ends share the same libvirt/KVM backend—mix & match UIs at will; VMs remain compatible.
