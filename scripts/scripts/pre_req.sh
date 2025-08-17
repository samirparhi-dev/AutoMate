#!/usr/bin/env bash
set -ex

# Install base packages including iptables and net-tools
apt-get update && apt-get install -y \
    sudo curl wget gnupg2 software-properties-common \
    xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils \
    xrdp lxde fonts-dejavu \
    libasound2 libatk-bridge2.0-0 libgtk-3-0 libnss3 libxss1 libxcomposite1 libxrandr2 libgbm1 \
    nano git ca-certificates gnupg lsb-release \
    iptables net-tools dnsutils lsof \
    && rm -rf /var/lib/apt/lists/*

# Remove snap and Snap Firefox (important to allow deb-based installation)
apt-get update && \
    apt-get purge -y snapd && \
    rm -rf ~/snap /snap /var/snap /var/lib/snapd && \
    rm -rf /var/lib/apt/lists/*
