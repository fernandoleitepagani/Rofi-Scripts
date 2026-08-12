<div align="center">

# Rofi-Scripts

**A collection of custom [Rofi](https://github.com/davatorium/rofi) scripts for a faster, keyboard-driven workflow.**

[![Shell Script](https://img.shields.io/badge/Shell-Bash-4EAA25?style=flat-square&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Rofi](https://img.shields.io/badge/Rofi-Compatible-2E9EF7?style=flat-square)](https://github.com/davatorium/rofi)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)
[![Stars](https://img.shields.io/github/stars/fernandoleitepagani/Rofi-Scripts?style=flat-square)](https://github.com/fernandoleitepagani/Rofi-Scripts/stargazers)

</div>

## 📖 About

This repo contains a set of Rofi scripts I use daily (or have used) to speed up common tasks — launching apps, managing windows, clipboard history, power menus, and more. I try to develop all scripts to be the most simple and theme-agnostic possible.
> [!IMPORTANT]
> All scripts have been developed and tested **only** on wayland

## </> List of Scripts
- rofi-info.sh -- Script for quickly showing some system information. It displays a notification with the information of the selected option. On the case of the wifi, bluetooth and audio options, it also gives you the possibility to open apps/TUIs to manage them (i.e. blueman-manager)
- rofi-mpris.sh -- Script for managing media. It shows you all the current playing media and let's you pause/play, stop, go to previous, go to next and shuffle for each.
- rofi-power.sh -- Simple script for log-out, shutdown, reboot and suspend 
- rofi-performance.py --  Script for choosing the current power mode (performance, balanced, power-saver)

## 🎨 Configuration and Themes

Most scripts share the default theming from your `.config.rasi` file.

## 🤝 Contributing

Issues and pull requests are welcome. If you have a rofi script you think fits well here, feel free to open a PR.

## 📄 License

Licensed under the [MIT License](LICENSE).
