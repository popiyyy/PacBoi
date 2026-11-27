# PacBoi — Pac-Man in VHDL (Digilent Basys 3)

Implementasi gim *arcade* **PacBoi** berbasis perangkat keras menggunakan **VHDL** pada papan FPGA **Digilent Basys 3** (Xilinx Artix-7 `XC7A35T`) dengan antarmuka **VGA 640×480 @ 60 Hz** (12-bit RGB), disintesis menggunakan **AMD Vivado**.

*(Diadaptasi dan dikembangkan dari repositori referensi `ilucasgoncalves/PacMan-VHDL` untuk Altera DE2 / Quartus II).*

---

## Fitur Utama

- **Kontrol & Animasi Pacman**: Gerak 4 arah di dalam labirin dengan sprite hadap kiri/kanan/atas/bawah serta animasi mulut buka-tutup saat bergerak.
- **2–3 Ghost & Kesulitan Dinamis**:
  - 2 Ghost aktif sejak awal permainan.
  - Ghost ke-3 muncul saat skor mencapai `>= 15` dengan pergerakan acak di seluruh jalur labirin.
  - Kecepatan ghost meningkat setiap kelipatan skor 5.
- **Sistem 2 Nyawa & Game Over**:
  - Indikator nyawa (2 ikon Pacman) di kiri bawah layar.
  - Layar **`KAMU KALAH`** menampilkan skor akhir dan opsi **`▶ LANJUT`** untuk memulai ulang permainan.
- **Menu Pause**: Tekan `btn_start` untuk menjeda permainan (seluruh pergerakan Pacman & ghost membeku) dengan pilihan **`1. LANJUTKAN`** dan **`2. ULANG`**.
- **Poin & Skor**:
  - Animasi poin kembang-kempis dengan *random respawn* (~3 detik) menggunakan LFSR.
  - Tampilan HUD seragam: **`SKOR = XX`** (kiri) dan **`SKOR TERTINGGI = XX`** (kanan).

---

## Kontrol Hardware (Basys 3)

| Sinyal | Pin | Komponen | Fungsi |
| :--- | :--- | :--- | :--- |
| `clk` | `W5` | Osilator 100 MHz | Clock utama sistem |
| `sw_reset` | `V17` | Slide Switch 0 | Reset sistem gim |
| `btn_start` | `U18` | Push Button Center | Pause / Konfirmasi menu |
| `btn_up` | `T18` | Push Button Up | Gerak atas / Navigasi menu |
| `btn_down` | `U17` | Push Button Down | Gerak bawah / Navigasi menu |
| `btn_left` | `W19` | Push Button Left | Gerak kiri |
| `btn_right` | `T17` | Push Button Right | Gerak kanan |

---

## Struktur Modul (`PACboi-Files/`)

- `top_level.vhd` — Integrasi struktural seluruh modul, kontrol state Pause/Game Over, dan *gating* input/clock.
- `clkdiv.vhd` — Pembagi clock 100 MHz menjadi `clk_25MHz` (VGA) dan `clk_game`.
- `VGASYNC.vhd` — Pembangkit sinyal sinkronisasi VGA (`hsync`, `vsync`, `video_on`, `pixel_row`, `pixel_column`).
- `msgHello.vhd` — Logika utama gim (pergerakan, *collision*, nyawa, skor, *high score*, dan *random respawn*).
- `CHAR_ROM.VHD` — ROM *sprite* 16×16 karakter, labirin, dan animasi.
- `pause_menu.vhd` — Overlay menu **PAUSE**, layar **KAMU KALAH**, dan label HUD **SKOR / SKOR TERTINGGI**.
- `YAKUZA_CONV.vhd` — Konverter warna 1-bit ke RGB 12-bit (`vgaRed`, `vgaGreen`, `vgaBlue`).
- `Basys-3-Master.xdc` — Pemetaan pin I/O FPGA Basys 3.

---

## Pratinjau Desain Awal (Referensi)

### MIF - Example
<p align="center">
<img src="imgs/MIF.PNG" />
</p>

### Final Map Design
<p align="center">
<img src="imgs/GUI.PNG" />
</p>
