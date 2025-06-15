<div align="center">

# 🌟 NekroShell

*The Ultimate Desktop Experience*

[![GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg?style=for-the-badge)](https://www.gnu.org/licenses/gpl-3.0)
[![QML](https://img.shields.io/badge/Built%20with-QML-darkgreen.svg?style=for-the-badge)](https://doc.qt.io/qt-6/qmlapplications.html)
[![QuickShell](https://img.shields.io/badge/Powered%20by-QuickShell-orange.svg?style=for-the-badge)](https://quickshell.org)
[![Hyprland](https://img.shields.io/badge/Optimized%20for-Hyprland-purple.svg?style=for-the-badge)](https://hyprland.org)

**A revolutionary desktop shell that delivers a universal, elegant experience across any tiling window manager with unmatched performance and aesthetic excellence.**

<img src="preview/preview.gif" alt="NekroShell Preview" width="800" style="border-radius: 12px; box-shadow: 0 8px 32px rgba(0,0,0,0.3);" />

*🎯 Seamless • 🎨 Beautiful • ⚡ Fast*

</div>

---

## ✨ Features That Define Excellence

<details>
<summary><b>🎮 Interactive Components</b></summary>

- **🖱️ Intelligent Bar System**: Dynamic workspace management with scroll navigation
- **🎯 Smart Launcher**: Fuzzy search with application and action support
- **📊 Live Dashboard**: Real-time system monitoring with beautiful visualizations
- **🔔 Modern Notifications**: Elegant notification system with popup management
- **⚙️ Quick Settings**: OSD controls for volume, brightness, and system settings
- **🔐 Session Manager**: Secure logout, shutdown, and system control

</details>

<details>
<summary><b>🎨 Visual Excellence</b></summary>

- **🌓 Dynamic Theming**: Light/dark mode with automatic scheme switching
- **🖼️ Wallpaper Integration**: Seamless wallpaper management with preview
- **🌈 Material Design 3**: Modern color palette with transparency effects
- **🎭 Smooth Animations**: Fluid transitions using Bézier curves
- **📐 Responsive Layout**: Adaptive UI that scales perfectly on any display
- **✨ Glass Morphism**: Beautiful blur effects and transparency layers

</details>

<details>
<summary><b>⚡ Performance & Integration</b></summary>

- **🚀 Native Performance**: Built on Qt/QML for optimal speed
- **🔗 Universal Compatibility**: Works with any tiling window manager
- **🎛️ Advanced Configuration**: JSON-based config with live reloading
- **🖥️ Multi-Monitor Support**: Perfect scaling across multiple displays
- **🎵 Media Control**: MPRIS integration with Spotify optimization
- **📡 System Integration**: Native D-Bus, network, and hardware support

</details>

---

## 🏗️ Architecture & Technical Deep Dive

<div align="center">
<img src="https://img.shields.io/badge/Architecture-Modular-brightgreen?style=for-the-badge" />
<img src="https://img.shields.io/badge/Config-JSON%20Based-blue?style=for-the-badge" />
<img src="https://img.shields.io/badge/Performance-Native%20Qt-red?style=for-the-badge" />
</div>

### 🧩 Modular Component System

NekroShell is architecturally designed with a sophisticated modular approach:

```
🏗️ Core Architecture
├── 🎯 shell.qml (Entry Point)
├── 📦 modules/ (UI Components)
│   ├── 🎪 background/ (Wallpaper System)
│   ├── 📊 bar/ (Status Bar & Popouts)
│   ├── 🎮 dashboard/ (System Dashboard)
│   ├── 🚀 launcher/ (Application Launcher)
│   ├── 🔔 notifications/ (Notification System)
│   ├── 🎛️ osd/ (On-Screen Display)
│   └── 🔐 session/ (Session Management)
├── 🔧 services/ (Backend Logic)
├── ⚙️ config/ (Configuration System)
├── 🎨 widgets/ (Reusable Components)
└── 🛠️ utils/ (Helper Functions)
```

### 🎯 Core Technologies

<table>
<tr>
<td>

**Frontend**
- 🎨 QML/QtQuick 6
- 🧩 QuickShell Framework
- 🎭 Qt Multimedia & Effects
- 📐 Responsive Layouts

</td>
<td>

**Backend**
- 🐧 Linux System APIs
- 🔗 D-Bus Integration
- 🎵 MPRIS Media Protocol
- 📡 NetworkManager

</td>
<td>

**Window Management**
- 🪟 Wayland Protocol
- 🎨 wlr-layer-shell
- 🔲 Hyprland IPC
- 🖥️ Multi-monitor Support

</td>
</tr>
</table>

### 🔧 Service Architecture

The shell operates through a sophisticated service layer:

| Service | Purpose | Key Features |
|---------|---------|--------------|
| 🖥️ **Hyprland** | Window manager integration | Real-time workspace tracking, client management |
| 🎵 **Players** | Media control | MPRIS integration, Spotify optimization |
| 🔊 **Audio** | Sound management | PipeWire integration, volume control |
| 🌐 **Network** | Connectivity | NetworkManager integration, Wi-Fi management |
| 🔋 **Brightness** | Display control | DDC/CI support, multi-monitor brightness |
| 📊 **SystemUsage** | Performance monitoring | CPU, memory, storage tracking |
| 🖼️ **Wallpapers** | Background management | Fuzzy search, preview system |
| 🔔 **Notifications** | Message system | D-Bus notification server |
| 🎨 **Colours** | Theme management | Dynamic color scheme switching |

---

## 🚀 Installation & Setup

### 📋 Prerequisites

<div align="center">

![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Fedora](https://img.shields.io/badge/Fedora-294172?style=for-the-badge&logo=fedora&logoColor=white)
![openSUSE](https://img.shields.io/badge/openSUSE-73BA25?style=for-the-badge&logo=openSUSE&logoColor=white)

</div>

**Required Dependencies:**
```bash
# Essential
quickshell     # The shell framework
qt6-multimedia # Qt6 multimedia support
qt6-svg        # SVG rendering

# System Integration
pipewire       # Audio system
networkmanager # Network management
brightnessctl  # Brightness control (or ddcutil)
cava          # Audio visualizer

# Optional but Recommended
hyprland      # Optimized window manager
fish          # Shell for scripts
```

### 🔧 Quick Install

<details>
<summary><b>📦 Arch Linux</b></summary>

```bash
# Install dependencies
paru -S quickshell-git qt6-multimedia qt6-svg pipewire networkmanager brightnessctl cava hyprland fish

# Clone NekroShell
git clone https://github.com/your-username/nekroshell.git
cd nekroshell

# Make scripts executable
chmod +x run.fish reload.fish

# Launch NekroShell
./run.fish
```

</details>

<details>
<summary><b>🐧 Ubuntu/Debian</b></summary>

```bash
# Add QuickShell repository (if available) or build from source
# Install dependencies
sudo apt install qt6-multimedia-dev qt6-svg-dev pipewire networkmanager cava fish

# Clone and setup (same as above)
git clone https://github.com/your-username/nekroshell.git
cd nekroshell
chmod +x run.fish reload.fish
./run.fish
```

</details>

<details>
<summary><b>🎩 Fedora</b></summary>

```bash
# Install dependencies
sudo dnf install qt6-qtmultimedia qt6-qtsvg pipewire NetworkManager cava fish

# Clone and setup
git clone https://github.com/your-username/nekroshell.git
cd nekroshell
chmod +x run.fish reload.fish
./run.fish
```

</details>

### ⚙️ Configuration

NekroShell uses a sophisticated JSON-based configuration system:

```bash
# Configuration directory
~/.local/state/nekroshell/
├── shell.json          # Main configuration
├── scheme.json         # Color scheme
└── wallpaper/
    └── path.txt        # Current wallpaper
```

**Key Configuration Options:**

<details>
<summary><b>🎨 Appearance Settings</b></summary>

```json
{
  "border": {
    "thickness": 10,
    "rounding": 25,
    "colour": "#1e1e2e"
  },
  "bar": {
    "workspaces": {
      "shown": 5,
      "rounded": true,
      "showWindows": false
    }
  }
}
```

</details>

<details>
<summary><b>🚀 Launcher Settings</b></summary>

```json
{
  "launcher": {
    "maxShown": 8,
    "maxWallpapers": 9,
    "actionPrefix": ">",
    "enableDangerousActions": false
  }
}
```

</details>

---

## 🎮 Usage & Shortcuts

### ⌨️ Global Shortcuts

| Shortcut | Action | Description |
|----------|--------|-------------|
| `Super + Space` | **Launch** | Toggle application launcher |
| `Super + D` | **Dashboard** | Open system dashboard |
| `Super + Shift + Q` | **Session** | Open session menu |
| `Super + A` | **Show All** | Toggle all panels |
| `Ctrl + Alt + R` | **Reload** | Restart NekroShell |

### 🎯 Launcher Actions

Access powerful actions by typing `>` in the launcher:

- `>scheme` - Change color scheme
- `>wallpaper` - Browse wallpapers
- `>variant` - Switch theme variant
- `>transparency` - Adjust transparency
- `>light` / `>dark` - Switch theme mode

### 🖱️ Mouse Interactions

- **Bar Scroll**: Navigate workspaces
- **Right Click**: Context menus
- **Drag**: Interactive elements
- **Hover**: Reveal additional controls

---

## 🎨 Customization & Themes

### 🌈 Color Schemes

NekroShell supports dynamic theming with Material Design 3:

<div align="center">
<img src="https://via.placeholder.com/100x50/1e1e2e/ffffff?text=Dark" alt="Dark Theme" />
<img src="https://via.placeholder.com/100x50/f8f8f2/000000?text=Light" alt="Light Theme" />
<img src="https://via.placeholder.com/100x50/7c3aed/ffffff?text=Purple" alt="Purple Theme" />
<img src="https://via.placeholder.com/100x50/06b6d4/ffffff?text=Cyan" alt="Cyan Theme" />
</div>

### 🖼️ Wallpaper System

- **Fuzzy Search**: Find wallpapers instantly
- **Live Preview**: See changes in real-time
- **Format Support**: JPG, PNG, WebP, TIFF
- **Directory Watching**: Auto-detect new wallpapers

### 🎭 Animation Curves

Professional animation system with custom easing:

```qml
// Expressive animations for spatial elements
easing.bezierCurve: [0.3, 0, 0.8, 0.15]

// Emphasized animations for important UI changes  
easing.bezierCurve: [0.3, 0, 0, 1]

// Standard deceleration for smooth interactions
easing.bezierCurve: [0, 0, 0.2, 1]
```

---

## 🔧 Development & Contributing

<div align="center">

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=for-the-badge)](http://makeapullrequest.com)
[![Code Style](https://img.shields.io/badge/code%20style-QML-yellow.svg?style=for-the-badge)](https://doc.qt.io/qt-6/qml-codingconventions.html)
[![Contributors](https://img.shields.io/github/contributors/your-username/nekroshell.svg?style=for-the-badge)](https://github.com/your-username/nekroshell/graphs/contributors)

</div>

### 🏗️ Development Setup

```bash
# Clone repository
git clone https://github.com/your-username/nekroshell.git
cd nekroshell

# Development cycle
./run.fish      # Launch NekroShell
# Make changes...
./reload.fish   # Hot reload changes
```

### 📝 Code Structure

```
📁 Development Guidelines
├── 🎨 QML Best Practices
├── 📦 Modular Architecture  
├── 🔧 Service-Oriented Design
├── ⚡ Performance Optimization
└── 📚 Comprehensive Documentation
```

### 🤝 Contributing

We welcome contributions! Here's how to get started:

1. **🍴 Fork** the repository
2. **🌿 Create** your feature branch (`git checkout -b feature/AmazingFeature`)
3. **💻 Commit** your changes (`git commit -m 'Add some AmazingFeature'`)
4. **📤 Push** to the branch (`git push origin feature/AmazingFeature`)
5. **🔀 Open** a Pull Request

### 🐛 Issue Reporting

Found a bug? Have a feature request? 

[![Report Bug](https://img.shields.io/badge/Report-Bug-red?style=for-the-badge)](https://github.com/your-username/nekroshell/issues/new?template=bug_report.md)
[![Request Feature](https://img.shields.io/badge/Request-Feature-blue?style=for-the-badge)](https://github.com/your-username/nekroshell/issues/new?template=feature_request.md)

---

## 🏆 Acknowledgments & Credits

<div align="center">

### 🙏 Special Thanks

**Based on the excellent [Caelestia Shell](https://github.com/caelestia-dots/shell)**  
*Foundation for this enhanced desktop experience*

</div>

<table align="center">
<tr>
<td align="center">
<img src="https://avatars.githubusercontent.com/u/QuickShell?s=100" width="100"><br>
<b>QuickShell Team</b><br>
<sub>Shell Framework</sub>
</td>
<td align="center">
<img src="https://avatars.githubusercontent.com/u/hyprwm?s=100" width="100"><br>
<b>Hyprland</b><br>
<sub>Window Manager</sub>
</td>
<td align="center">
<img src="https://qt.io/favicon.ico" width="100"><br>
<b>Qt Project</b><br>
<sub>UI Framework</sub>
</td>
<td align="center">
<img src="https://material.io/favicon.ico" width="100"><br>
<b>Material Design</b><br>
<sub>Design Language</sub>
</td>
</tr>
</table>

---

## 📄 License

<div align="center">

**NekroShell** is licensed under the **GNU General Public License v3.0**

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg?style=for-the-badge)](https://www.gnu.org/licenses/gpl-3.0)

*Freedom to use, modify, and distribute*

</div>

**Made with ❤️ by FelipeFMA**

[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/your-username/nekroshell)


*⭐ Star the project on GitHub — it helps!*

</div>

---

## If you like what I do, please consider donating :)
Bitcoin:
`bc1qnkq7hf6r53fg73jh3awfsn6ydeh87u5cf8hs3g`

![bitcoin](https://github.com/user-attachments/assets/9aaf40c6-6bdb-4480-8bdd-05b9023613d9)

Ko-fi:
https://ko-fi.com/felipefma

Paypal:
felipefmavelar@gmail.com

Brazilian Pix:
felipefmavelar@gmail.com

---
