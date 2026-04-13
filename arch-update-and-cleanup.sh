# Update packages and forse database refresh
sudo pacman -Syyu
# Delete orphan packages
sudo pacman -Qtdq
# To delete package with dependancies use this:
# sudo pacman -Rns <package_name>
