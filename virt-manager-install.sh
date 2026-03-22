  sudo pacman -S virt-manager qemu-desktop libvirt dnsmasq
  sudo systemctl enable --now libvirtd
  sudo usermod -aG libvirt $USER

