<div align="center">

# Rofi-Scripts

**A collection of custom [Rofi](https://github.com/davatorium/rofi) scripts for a faster, keyboard-driven workflow.**

[![Shell Script](https://img.shields.io/badge/Shell-Bash-4EAA25?style=flat-square&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Rofi](https://img.shields.io/badge/Rofi-Compatible-2E9EF7?style=flat-square)](https://github.com/davatorium/rofi)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)
[![Stars](https://img.shields.io/github/stars/fernandoleitepagani/Rofi-Scripts?style=flat-square)](https://github.com/fernandoleitepagani/Rofi-Scripts/stargazers)

</div>

## 📖 About

This repo contains a set of Rofi scripts I use daily to speed up common tasks — launching apps, managing windows, clipboard history, power menus, and more. Each script is self-contained, lightweight, and easy to theme.

Click into each section below to see a short demo of the script in action.

## 📑 Table of Contents

- [Scripts](#-scripts)
  - [Power Menu](#power-menu)
  - [Clipboard Manager](#clipboard-manager)
  - [App Launcher](#app-launcher)
- [Contributing](#-contributing)
- [License](#-license)

## 🧩 Scripts

### Power Menu
Shutdown, reboot, lock, log out, and suspend

**Usage:**
```bash
./scripts/power-menu.sh
```

<details>
<summary>▶️ Click to view demo</summary>
<br>

<!-- Paste your video/gif here, e.g.:
https://github.com/user-attachments/assets/your-video-id
-->

</details>

### Clipboard Manager

Browse and paste from your clipboard history without leaving the keyboard.

**Dependencies:** `wl-clipboard`

**Usage:**
```bash
./scripts/clipboard.sh
```

<details>
<summary>▶️ Click to view demo</summary>
<br>

<!-- Paste your video/gif here -->

</details>

### App Launcher

A themed drop-in replacement for the default `rofi -show drun` launcher.

**Usage:**
```bash
./scripts/launcher.sh
```

<details>
<summary>▶️ Click to view demo</summary>
<br>

<!-- Paste your video/gif here -->

</details>

---

## 🎨 Configuration and Themes

Most scripts read shared theming from [`config/theme.rasi`](config/theme.rasi). Edit colors, fonts, and sizing there to restyle every script at once.

## 🤝 Contributing

Issues and pull requests are welcome. If you have a rofi script you think fits well here, feel free to open a PR.

## 📄 License

Licensed under the [MIT License](LICENSE).
