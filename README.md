# 📚 Bukoo - Digital Library App

**Bukoo** adalah aplikasi katalog dan penyewaan buku digital yang dibangun menggunakan Flutter. Aplikasi ini dirancang untuk memberikan pengalaman eksplorasi buku yang serealistis mungkin dengan performa yang dioptimalkan.

---

## 🚀 Fitur Utama

- **Authentication**: Login & Register aman menggunakan **Firebase Auth**.
- **Smart Catalog**: Menampilkan daftar buku dengan fitur **Lazy Loading (Pagination)** untuk menghemat kuota dan memori.
- **Discovery Mode**: 
  - **Filter Genre**: Eksplorasi buku berdasarkan kategori favorit.
  - **Random Book**: Fitur "Buku Acak" untuk kamu yang bingung mau baca apa.
- **Personalized List**: Simpan buku incaran ke dalam daftar **Favorit** (tersimpan di Firestore).
- **Dynamic View**: Toggle tampilan antara **List View** (detail) atau **Grid View** (fokus sampul).
- **Smooth Interaction**: Navigasi cepat menggunakan **GetX** dan manajemen state dengan **Riverpod**.

---

## 🛠️ Tech Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **Backend**: Firebase (Auth & Firestore)
- **Networking**: Dio (untuk consume Public API)
- **Navigation**: GetX
- **Localizations**: Intl (untuk format mata uang Rupiah)

---

## 📺 Demo & Dokumentasi

- 🎥 **Video Review Aplikasi**: [![bukoo.](https://img.youtube.com/vi/N5A87eoGaO0/0.jpg)](https://www.youtube.com/watch?v=N5A87eoGaO0)
- 📦 **Download APK**: [Klik di Sini untuk Download APK Bukoo](https://drive.google.com/drive/folders/1eJ8EXUwMYGRISmfIpgcSWBWLm_jE8Fav?usp=drive_link)

---

## 🏗️ Struktur Project (Clean Code)

Proyek ini meminimalisir penggunaan data `dynamic` dengan mengimplementasikan Data Models untuk response API maupun payload Firestore, sesuai dengan prinsip *type-safety* di Dart.
