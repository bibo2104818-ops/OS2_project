
 _________________                 
| #Title          |
| #Description    |
| #Features       |
| #Technologies   |
| #Installation   |
| #Usage          |
| #Structure      |
| #Author         |
|_________________|



# OS2_project
##Linux System Audit and Monitoring (Mini Project)



## 🎓 Academic Information

- **Course**: Operating Systems 2 (SYST 2)
- **Institution**: National School of Cyber Security (NSCS)
- **Academic Year**: 2025/2026
- **Instructor**: Dr. BENTRAD Sassi
- **students**: promo 2


## 📌 Project Overview

This project is part of the *Operating Systems 2 (SYST 2)* course at the National School of Cyber Security.

The objective is to design and implement an automated **Linux audit and monitoring system** using shell scripting. The system collects hardware and software information, generates reports, and supports automation and remote monitoring.


## 💡 Project Idea

English :

This project was proposed by the instructor to highlight the importance of system auditing in Cybersecurity.

In modern computing environments, understanding both hardware and software configurations is essential for:
- Risk assessment
- Vulnerability management
- Incident response

Manual system auditing is often inefficient and error-prone. For this reason, the project focuses on automating these tasks using Linux shell scripting.

The main idea is to design and implement an automated solution capable of:
- Collecting detailed system information
- Monitoring system activity
- Generating structured reports
- Supporting security analysis and system management

This project reflects real-world tasks performed by system administrators and cybersecurity analysts, making it both practical and relevant.

*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
French :

Ce projet a été proposé par l’enseignant afin de mettre en évidence l’importance de l’audit des systèmes en cybersécurité.

Dans les environnements informatiques modernes, la compréhension des configurations matérielles et logicielles est essentielle pour :
- L’évaluation des risques
- La gestion des vulnérabilités
- La réponse aux incidents

L’audit manuel des systèmes est souvent inefficace et sujet aux erreurs. C’est pourquoi ce projet se concentre sur l’automatisation de ces tâches à l’aide de scripts shell sous Linux.

L’objectif principal est de concevoir et de développer une solution automatisée capable de :
- Collecter des informations détaillées sur le système
- Surveiller l’activité du système
- Générer des rapports structurés
- Aider à l’analyse de sécurité et à la gestion du système

Ce projet reflète des tâches réelles effectuées par les administrateurs systèmes et les analystes en cybersécurité, ce qui le rend pratique et pertinent.

*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*


## 🎯 Objectives

The system is designed to:

- Collect hardware information
- Collect software and OS information
- Generate formatted reports (short and detailed)
- Send reports via email
- Automate execution using cron jobs
- Support remote monitoring via SSH


## ⚙️ Technologies Used

- OS: Linux (Ubuntu / Kali / etc.)
- Language: Bash (Shell scripting)
- Tools: cron, SSH, mail utilities





## 📌 Features

### 1. Hardware Audit (Hardware Information Collection)
Retrieve detailed information about the machine’s hardware components, including :
- CPU information (model, cores, architecture)
- GPU (if available)
- RAM details (total and available memory)
- Disk information (size, partitions, usage,filesystem type)
- Network interfaces
- MAC and IP addresses
- Motherboard information and other relevant hardware details
- USB devices

### 2. Operating System & Software Audit (OS & Software Information Collection)
Extract comprehensive information about the operating system and installed software, including :
- OS name and version
- Kernel version
- System architecture
- Installed packages
- Logged-in users
- Running services and Active processes
- Open ports
- Etc.

### 3. Reporting System

- Short Report (summary)
- Full Report (detailed)

Formats:

- .txt / .html / .json / .pdf

Includes:

- Date & time
- Hostname
- Structured sections

Saved in:

### 4. Email Reporting

- Send reports via email
- Configurable recipient
- Tools: mail, mailx, sendmail

---


### 5. Automation

- Cron scheduling (e.g., daily at 04:00 AM)
- Logging execution
- Error handling

---


### 6. Remote Monitoring

- Monitoring via SSH
- Secure remote access
- Centralized reporting

---

###configuration
For email sending script youo should add this to email.conf & email.conf_2:

*email.conf* :  go to "user" and "from"  and add your gmail : example@gmail.com ---> replace example by your corresponding gmail
*** go to password and add application password *be cereful, never enter your password under any circumstances. Nothing will ask you for your password only when using root privileges* to get app password do this following:

✅ Step 1: Enable 2-Step Verification

App passwords only work if 2FA is enabled.

Go to your Google Account settings:
👉 https://myaccount.google.com/security
Find “2-Step Verification”
Click it and follow the steps (phone number, SMS code, etc.)

✅ Step 2: Generate App Password

After enabling 2FA:

Go to:
👉 https://myaccount.google.com/apppasswords
Sign in again if asked
Under “Select app”, choose:
Mail (or the app you need).
Under “Select device”, choose:
Your device (or “Other” and type a name like MyPC).
Click Generate.
Google will show a 16-character password like:
azed oiun hdgy tefd 👉 you should write it without space like: azedoiunhdgytefd

⚠️ Important Notes
This password is shown only once.
Do NOT share it with anyone.
You can revoke it anytime from the same page.
It’s used for apps that don’t support modern Google login.

*------------------------------------------------------------------------------------------------------------------------------------------------------*

*email.conf_2* : Go to set realname="name" replace name by your name.
set from="example@gmail.com"  ---> replace example by your corresponding gmail
*-----------------------------------------------------------------------------------*



## 📦 Installation

To use these scripts effectively, you must first download some tools :

# To use hardware_info.sh you should install all this:

sudo apt install -y \
util-linux \
pciutils \
usbutils \
dmidecode \
lm-sensors \
iproute2 \
ethtool \
pandoc \
texlive-xetex \
texlive-fonts-recommended \
texlive-latex-extra \
gawk \
sed \
grep \
coreutils \
procps \
net-tools

sudo sensors-detect
Answer YES to all prompts (recommended).


# To use Software Audit Script

sudo apt install -y \
procps \
iproute2 \
net-tools \
psmisc \
coreutils \
gawk \
sed \
grep \
util-linux \
hostname \
systemd \
pandoc \
texlive-xetex \
texlive-fonts-recommended \
texlive-latex-extra

 
# To use File Comparison Tool

sudo apt install -y \
diffutils \
coreutils \
grep \
findutils \
gawk \
sed

# To use Script Scheduler Tool

sudo apt install -y \
cron \
coreutils \
grep \
sed \
gawk \
util-linux

sudo systemctl enable cron
sudo systemctl start cron

# Email Sender Tool

sudo apt install -y mutt
sudo apt install -y msmtp msmtp-mta
sudo apt install -y mailutils

# To use Remote Audit Tool & SSH setup
sudo apt install -y openssh-client
sudo apt install -y openssh-client
sudo apt install -y coreutils

sudo apt install -y openssh-client openssh-server




## 🏗️ Project Structure

OS2_project-main/
├── config
│   ├── email.conf
│   └── email.conf_2
├── difficulties_faced.txt
├── generators
│   ├── generate_doc.sh
│   └── generate_pdf.sh
├── README.md
└── scripts
    ├── collected_report
    │   ├── _2026-03-19
    │   │   ├── hardware_full_report.txt
    │   │   ├── hardware_short_report.txt
    │   │   └── integrity_hashes.txt
    │   └── _2026-03-20
    │       ├── hardware_full_report.txt
    │       ├── hardware_short_report.txt
    │       ├── integrity_hashes.txt
    │       ├── software_full_report.txt
    │       └── software_short_report.txt
    ├── comparing_report.sh
    ├── cron_script.sh
    ├── hardware_info.sh
    ├── install.sh
    ├── main.sh
    ├── output
    │   ├── full_hardware_info.txt
    │   ├── hardware_info_20260303_034458.pdf
    │   ├── hardware_info_20260303_034650.pdf
    │   ├── hardware_report.pdf
    │   └── temp
    │       └── hardware_info.txt
    ├── remote_access.sh
    ├── run.sh
    ├── send_email.sh
    ├── setup_ssh.sh
    └── software_info.sh






#Athor

This project was made by Lahlouh AbdElJalil and Imad Taibi, students at the National School of Cybersecurity

Lahlouh AbdEljalil : 
GitHub account : bibo2104818-ops
Gmail : bibo2104818@gmail.com

Imad Taibi:
GitHub account : imadtaibi573-design
Gmail : imadtaibi573@gmail.com

Link of project : https://github.com/bibo2104818-ops/OS2_project.git
