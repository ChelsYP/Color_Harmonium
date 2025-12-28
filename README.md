# Color_Harmonium
🎨 Color Harmonium

A Linux GUI Application for Managing Clothing Collections and Color-Based Outfit Recommendations

📌 Overview

Color Harmonium is a graphical clothing management application built using Bash, Zenity, and jq. The application enables users to organize clothing collections, categorize them by type and color, and receive intelligent outfit recommendations based on seasonal themes. All data is stored in structured JSON format to ensure portability and ease of maintenance.

✨ Key Features

User-friendly graphical interface powered by Zenity

Persistent storage using structured JSON

Comprehensive predefined color dataset and grouping

Automated outfit pairing recommendations based on seasonal themes:

AUTUMN 🍂

SPRING 🌼

SUMMER ☀️

WINTER ❄️

Full CRUD functionality:

Add clothing items

View clothing collections

Generate outfit recommendations

Delete clothing entries

🛠️ Technology Stack

Bash Shell Scripting

Zenity (Linux graphical dialog interface)

jq (JSON data processing)

📥 Installation & Setup
1️⃣ Install Required Dependencies

Ensure that Zenity and jq are installed on your Linux system.

For Fedora / RHEL:

sudo dnf install zenity jq -y


For Ubuntu / Debian:

sudo apt install zenity jq -y

2️⃣ Save the Script

Save the script file as:

color-harmonium.sh

3️⃣ Grant Execution Permission
chmod +x color-harmonium.sh

4️⃣ Run the Application
./color-harmonium.sh

📂 Data Structure
koleksi.json

Stores the clothing collection data:

[
  {
    "jenis": "Atasan",
    "nama": "Black Shirt",
    "warna": "black"
  }
]

warna.json

Contains the predefined color dataset (automatically generated if not available).

📌 Main Menu Functions

Upon launching, the application provides the following options:

👕 Add Clothing Item

🧾 Display Clothing Collection

🎯 Color Recommendation

🗑 Delete Clothing Item

🚪 Exit Application

⚙️ Functional Workflow

The user interacts with the system via Zenity dialogs.

Clothing data is stored and manipulated using JSON via jq.

Recommendations are generated through pattern-based color matching.

Results are displayed using Zenity text dialogs for clarity and convenience.

🧪 Testing Guidance

To verify proper functionality:

Add at least one Top (Atasan) and Bottom (Bawahan)

Validate the collection display feature

Generate outfit recommendations across all seasonal themes

Test deletion functionality and confirm updates to the dataset

📝 Notes

This application is designed for Linux desktop environments that support Zenity.

The predefined color dataset can be customized and expanded.

Suitable for personal use, academic projects, and demonstrative purposes.

👨‍💻 Developer Statement

This project was developed to demonstrate a practical implementation of graphical user interaction in Linux using shell scripting, JSON data handling, and color-based recommendation logic.
