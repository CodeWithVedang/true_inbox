# 📱 TrueInbox – Smart & Secure SMS Inbox (Flutter)

TrueInbox is a modern **Flutter-based Android application** designed to make SMS safer, smarter, and easier to manage.

The app automatically reads and analyzes inbox messages (with user permission) and classifies them into meaningful categories such as:

- ✅ OTP & Verification messages  
- 🏦 Transactional alerts (bank updates, payments, services)  
- 📢 Promotional / marketing messages  
- ⚠️ Malicious & phishing SMS with suspicious links

TrueInbox highlights risky messages and helps users quickly identify **important OTPs and scam threats**, all while keeping user data **completely on the device for privacy**.

---

---

## 🚀 Key Highlights

✅ **Real SMS parsing** using Android Telephony APIs  
✅ **Category-wise inbox organization**  
✅ **OTP detection with one-tap copy**  
✅ **Malicious link & scam message detection**  
✅ **TRAI header awareness for unregistered senders**  
✅ **Risk scoring system (0–100)** for message safety  
✅ **Smart dashboard with top risk widgets**  
✅ **Skeleton loader for fast smooth UX**  
✅ **Onboarding shown only once** (Splash → Onboarding → Home)  
✅ **Material 3 UI with smooth animations**  
✅ **100% on-device processing — zero data leaves your phone**

---

---

## 📊 Dashboard Cards

The home screen features interactive dashboard cards:

| Card | Purpose |
|------|---------|
| 📥 **Inbox Risk** | Shows overall SMS safety score |
| ⚠️ **Malicious SMS** | Lists risky and phishing messages |
| ⏰ **Smart Reminders** | Surfaces time-sensitive alerts |
| 💸 **Financial Stress** | Detects EMI, overdue & transactional alerts |

Each box opens to a dedicated security or insights view.

---

---

## 🔍 OTP Detection & Copy

TrueInbox intelligently recognizes OTP patterns:

✅ Matches keywords like `OTP`, `verification code`, `login code`  
✅ Extracts numeric OTP dynamically  
✅ One-tap **Copy OTP** button  
✅ Shows toast/snackbar confirmation

---

---

## 🛡️ Scam & Link Detection

The system detects potential phishing by analyzing:

- URL presence (short URLs, unknown domains)
- Unregistered TRAI headers
- Suspicious keyword patterns

Each message is assigned a **Risk Score (0–100)**:

| Risk Score | Meaning |
|------------|----------|
| 🟢 0–39 | Safe |
| 🟠 40–69 | Potentially risky |
| 🔴 70+ | High scam/phishing risk |

Users can tap **“Why this score?”** to see transparent explanations.

---

---

## 🔐 Privacy First

✔️ SMS analysis is done **locally on-device**  
✔️ No messages are uploaded  
✔️ No external servers used  
✔️ No tracking or ads

This is an academic prototype focused on demonstrating mobile ML & SMS safety concepts.

---

---

## 💻 Tech Stack

| Layer | Technology |
|------|--------------|
| UI Framework | Flutter (Material 3) |
| Language | Dart |
| State Mgmt | Provider |
| Permissions | Android Telephony APIs |
| Local Storage | SharedPreferences |
| Classification | Heuristic + Rule-based logic |
| Animations | Native Flutter transitions |

---

---

## 📁 Project Structure

true_inbox/
│
├── lib/
│ ├── models/
│ ├── providers/
│ ├── ui/
│ │ ├── screens/
│ │ ├── widgets/
│ └── main.dart
│
├── assets/
│ └── icon/
├── android/
├── pubspec.yaml
└── README.md

---

---

## ▶️ Running the App Locally

### Prerequisites
- Flutter SDK installed
- Android device or emulator

### Run:


---

## 📦 APK Download

You can download and install the latest release APK directly from GitHub:

👉 **Download APK:**

```
https://github.com/CodeWithVedang/true_inbox/releases/download/V1/app-release.apk
```


---

## 🔨 Building Release APK

To generate a production APK yourself:

```bash
flutter build apk --release
```

The APK will be created at:

```
build/app/outputs/flutter-apk/app-release.apk
```

Transfer this file to your Android phone to install.

---

---

## 📲 Installation Steps

1. Download the `app-release.apk` from the link above.
2. Open it on your Android device.
3. Allow installation from unknown sources if prompted.
4. Launch **TrueInbox** and grant SMS permissions.

---


## 🧠 Academic Use

This project was developed as a **Mobile Application Development & Security Analytics mini-project**, demonstrating:

* On-device mobile data classification.
* SMS threat analysis without cloud dependency.
* Secure permission handling and privacy-first UX.
* Flutter Material-3 UI implementation.
* Android Telephony-based system integration.

---


## 🚧 Future Enhancements

🔹 Machine learning & NLP models for dynamic scam detection
🔹 Online phishing URL reputation APIs
🔹 AI-powered personalized SMS filtering
🔹 Multilingual SMS support
🔹 Cloud optional OSINT checks (opt-in)
🔹 iOS limitations research version
🔹 Full Android default SMS app integration

---



## 🧾 Limitations

* iOS cannot provide SMS access due to system restrictions.
* This project does not yet replace the default Android SMS app.
* Scam detection currently uses rule-based logic (ML is future planned).

---



## 👨‍💻 Author

**Vedang Shelatkar**

📍 India
📧 *shelatkarvedang2@gmail.com*
🌐 GitHub: [https://github.com/CodeWithVedang](https://github.com/CodeWithVedang)

---

---

## ⭐ Support

If you like this project or found it useful:

✅ Give it a star ⭐ on GitHub
✅ Share with fellow developers
✅ Provide feedback or suggestions

---

---

## 📄 License

This project is released under the MIT License and is open-source for educational and demonstration use.
