<p align="center">
  <img src="Image/Gemini_Generated_Image_8ackdl8ackdl8ack.png" alt="MyXenPay Banner" width="100%">
</p>

# MyXenPay (Super Application) Mobile App

[![Flutter Version](https://img.shields.io/badge/Flutter-3.13+-blue?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/bikkhoto/MyXen-Mobile-Application?style=social)](https://github.com/bikkhoto/MyXen-Mobile-Application/stargazers)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)]()

---

## 💡 Overview

MyXenPay is a secure, minimal, **Super Application** built on the **Solana** blockchain. It provides a non-custodial wallet and comprehensive payment services for both **Android** and **iOS** devices, focusing on security and community features.

This repository contains the full source code for the mobile client, developed using the **Flutter** framework.

### Why MyXenPay?

MyXenPay aims to be more than just a wallet. We offer a holistic financial experience centered around the **$MYXN** token (SPL, 9 decimals) with a focus on institutional and educational support.

---

## ✨ Key Features

| Category | Features |
| :--- | :--- |
| **Security & Wallet** | **Hardware-backed** Keystore support, Biometric + PIN authentication, **On-device signing**, BIP39 mnemonic support, AES-256-GCM encryption. |
| **Payments** | Seamless **MyXenPay** (Send/Receive $MYXN), **QR Code Scanner** for merchant payments, on-chain transaction history. |
| **Community** | Encrypted **KYC** and **Seed Vault** features, Emergency **SOS** capability, read-only status for **Scholarship Programs** and **Female Empowerment** initiatives. |
| **Tools** | Account management, Trusted Merchant Indicators, support for University Student zero-fee payments. |

---

## 🛠️ Tech Stack & Requirements

This application is built entirely with **Flutter** for a unified cross-platform experience.

* **Framework:** [Flutter](https://flutter.dev/) (Targeting Android 7.0+ / iOS 12+)
* **State Management:** Riverpod
* **Storage:** `flutter_secure_storage` (Secure Storage) and `drift/sqflite` (Local Database)
* **Blockchain:** Solana SDK (for Dart/Flutter)

### Prerequisites

To build and run this project, you need:

1.  **Flutter SDK** (Latest Stable Channel)
2.  **Dart SDK**
3.  **Android Studio** or **Xcode** (for platform-specific builds)

---

## ⚙️ Getting Started

Follow these steps to set up the development environment.

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/bikkhoto/MyXen-Mobile-Application.git
    cd MyXen-Mobile-Application
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Configure Environment Variables:**
    Create a `.env` file in the root directory based on the provided [`.env.example`](.env.example).
    ```bash
    MYXEN_API_BASE_URL=https://api.myxenpay.finance
    MYXEN_RPC_URL=https://rpc.myxenpay.finance
    FEATURE_KYC_ENCRYPTION=true
    ```
4.  **Run the application:**
    ```bash
    flutter run
    ```

---

## 📝 Governance & Contributions

We welcome and encourage community contributions. Please review the following guidelines before submitting any code or reporting issues.

| Policy | File Link | Purpose |
| :--- | :--- | :--- |
| **Code of Conduct** | [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) | Defines the standards for behavior within the community. |
| **Contributing Guide** | [CONTRIBUTING.md](CONTRIBUTING.md) | Details how to submit bug reports, feature requests, and pull requests. |
| **Security Policy** | [SECURITY.md](SECURITY.md) | Explains how to privately report vulnerabilities to the maintainers. |
| **License** | [LICENSE](LICENSE) | The project is released under the **MIT License**. |

---

## 📧 Contact

For support or questions, please open an [Issue here](https://github.com/bikkhoto/MyXen-Mobile-Application/issues).
