# acore-scripts

![GitHub stars](https://img.shields.io/github/stars/ahmet-cetinkaya/acore-scripts?style=social) ![GitHub forks](https://img.shields.io/github/forks/ahmet-cetinkaya/acore-scripts?style=social) [![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?&logo=buy-me-a-coffee&logoColor=black)](https://ahmetcetinkaya.me/donate)

A collection of reusable bash scripts to eliminate code duplication across projects. These scripts provide common utilities for logging, changelog generation, version management, and more.


## ⚡ Getting Started

### 📋 Requirements

- Unix/Linux shell (bash 3.2+)
- Git (for changelog and version management features)

### 🛠️ Installation

#### Method 1: Git Submodule (Recommended)
```bash
cd your-project
git submodule add https://github.com/ahmet-cetinkaya/acore-scripts.git scripts/acore
git submodule update --init --recursive
```

#### Method 2: Clone Directly
```bash
git clone https://github.com/ahmet-cetinkaya/acore-scripts.git
cd acore-scripts
```

#### Method 3: Copy Scripts
```bash
# Copy specific scripts to your project
cp acore-scripts/src/logger.sh your-project/scripts/
cp acore-scripts/src/_common.sh your-project/scripts/
```

## 📚 Documentation

For detailed requirements and design decisions, see the [Product Requirements Document](docs/PRD.md).

## 🤝 Contributing

If you'd like to contribute, please follow these steps:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

### Guidelines

- Keep scripts POSIX compliant where possible
- Add inline documentation for new functions
- Test scripts across different platforms (Linux, macOS, WSL)
- Follow existing code style and patterns

## 📄 License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- All contributors who help improve these scripts
- The open-source community for inspiration and best practices