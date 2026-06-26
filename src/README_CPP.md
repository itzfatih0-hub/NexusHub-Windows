# NEXUS EXECUTOR — C++ CORE

## Deskripsi

Bagian ini berisi kode C++ yang menjadi inti dari Nexus Executor, menangani:
- **Injeksi DLL** ke proses Roblox
- **Manipulasi Memori** untuk eksekusi script
- **Hooking API** untuk menghindari deteksi
- **Utilitas** untuk operasi sistem level rendah

## Struktur Folder

- `/core/`     : Manajemen utama executor
- `/injector/` : Logika injeksi DLL
- `/memory/`   : Membaca/menulis memori proses
- `/hooks/`    : Mencegat panggilan API Windows
- `/utils/`    : Fungsi bantuan (file, log, dll.)

## Build

- **Visual Studio**: Buka `.sln` dan build
- **CMake**: `mkdir build && cd build && cmake .. && make`
- **MinGW**: `g++ main.cpp core/*.cpp injector/*.cpp -o nexus_core.exe`

## Integrasi dengan Python

Kode C++ ini akan dikompilasi menjadi DLL atau EXE yang kemudian:
1. Dipanggil oleh Python GUI menggunakan `ctypes` atau `subprocess`
2. Berjalan sebagai service background untuk injeksi

## Keamanan

Kode ini menggunakan teknik standar untuk injeksi dan hooking.
Semua fungsi dilindungi dengan error handling yang ketat.

## Kredit

Dikembangkan oleh **PROFESOR_FATIH + NEXUS 1.0** untuk tujuan edukasi.