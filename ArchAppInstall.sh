#!/bin/bash

# Script Emir-Prime version Arch Linux
USER_ACTUEL=$(whoami)
set -e

echo "Attente de 1 seconde avant de commencer..."
sleep 1

echo "Lancement de l'installation Emir-Prime (Arch Linux Edition)..."
echo "Utilisateur détecté : $USER_ACTUEL"

demander_confirmation() {
    read -p "Voulez-vous installer / configurer : $1 ? [y/N] : " choix
    case "$choix" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

# =====================================================================
# 1. METTRE A JOUR
# =====================================================================
if demander_confirmation "Mise à jour du système"; then
    sudo pacman -Syu --noconfirm
fi

# =====================================================================
# 2. Installer FastFetch
# =====================================================================
if demander_confirmation "L'installation de FastFetch"; then
    sudo pacman -S --noconfirm fastfetch
fi

# =====================================================================
# 2.5. Installer Les Outils pour La compilation de linux
# =====================================================================
if demander_confirmation "L'installation des outils kernel linux"; then
    sudo pacman -S --noconfirm base-devel ncurses bison flex libelf bc cpio perl tar xz mkinitcpio grub ovmf guestfs-tools net-tools
fi

# =====================================================================
# 3. WINE
# =====================================================================
if demander_confirmation "Installation de Wine (32-bit et 64-bit)"; then
    # Activer le dépôt multilib si ce n'est pas déjà fait
    sudo sed -i "/\[multilib\]/,/^Include/"'s/^#//' /etc/pacman.conf
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm wine wine-mono wine_gecko
fi

# =====================================================================
# 4. OUTILS DE DEV & WEB
# =====================================================================
if demander_confirmation "Les outils de Dev, Serveur Web Apache et MariaDB"; then
    sudo pacman -S --noconfirm nasm base-devel python python-pip qemu-full clang gimp wget gnupg gcc apache mariadb
    sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
    sudo systemctl enable --now mariadb.service
    sudo systemctl enable --now httpd.service
fi

# =====================================================================
# 4.5. DISCORD ET STEAM
# =====================================================================
if demander_confirmation "L'installation de Discord et Steam"; then
    sudo pacman -S --noconfirm discord steam
fi

# =====================================================================
# 5. CONFIGURATION FLATPAK
# =====================================================================
if demander_confirmation "Le gestionnaire Flatpak et le dépôt Flathub"; then
    sudo pacman -S --noconfirm flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    APPS=("org.vinegarhq.Sober" "org.vinegarhq.Vinegar" "com.adobe.Flash-Player-Projector" "com.jpexs.decompiler.flash" "org.videolan.VLC" "com.mattjakeman.ExtensionManager")

    for app in "${APPS[@]}"; do
        if demander_confirmation "Installer $app ?"; then
            flatpak install -y flathub "$app"
        fi
    done
fi

# =====================================================================
# 6. NETTOYAGE et REDEMARRAGE FINAL
# =====================================================================
echo "Nettoyage du cache pacman..."
sudo pacman -Sc --noconfirm

echo "Installation terminée !"
if demander_confirmation "Veux-tu redémarrer maintenant pour appliquer les changements ?"; then
    sudo reboot
else
    echo "Redémarrage annulé."
fi
