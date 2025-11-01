# ZX Spectrum on Tang Nano 9K FPGA
## English (EN)
### Overview

This project implements a ZX Spectrum on a Tang Nano 9K FPGA. It runs classic Spectrum BASIC programs and supports automated typing via the included my_fsm module.

### Features

Runs ZX Spectrum BASIC programs

Typist module (my_fsm) for automated program entry

HDMI output: 1024x768 @ 24Hz (4x scale), no border

Fully implemented in Verilog, except for the CPU (Z80)

Video memory using Gowin DPB RAM

Supports multiple RAM/ROM blocks

### Future Plans

Keyboard input

Tape module for saving/loading programs from SD card using original SAVE/LOAD commands

Sound via HDMI

### Usage

1. **Clone this repository**
   ``` https://github.com/BorsosIstvan/zx_spectrum_v1.git```
2. Install the Gowin IDE (latest version recommended).
3. Obtain a Tang Nano 9K or 20K FPGA board.
4. Open the project in Gowin IDE ```zx_spectrum_v1.gprj```
5. Connect the Tang Nano board via USB.
6. Program the FPGA directly from Gowin IDE.
7. Connect the FPGA to a TV/monitor using HDMI.
8. Power on and enjoy the ZX Spectrum running on real FPGA hardware!
9. Use the key.py program voor keyboard

## Nederlands (NL)
### Overzicht

Dit project implementeert een ZX Spectrum op een Tang Nano 9K FPGA. Het kan klassieke Spectrum BASIC-programma’s draaien en ondersteunt automatisch typen via de my_fsm module.

### Functies

Draait ZX Spectrum BASIC-programma’s

Typist module (my_fsm) voor automatisch invoeren van programma’s

HDMI-uitvoer: 1024x768 @ 24Hz (4x scale), geen border

Volledig geïmplementeerd in Verilog, behalve de CPU (Z80)

Videogeheugen via Gowin DPB RAM

Ondersteunt meerdere RAM/ROM-blokken

### Toekomstplannen

Toetsenbordondersteuning

Tape-module voor opslaan/laden van programma’s vanaf SD-kaart met originele SAVE/LOAD commando’s

Geluid via HDMI

### Gebruik

1. **Kloon deze repository**  ``` https://github.com/BorsosIstvan/zx_spectrum_v1.git```
2. Installeer de Gowin IDE (bij voorkeur de nieuwste versie).
3. Koop een Tang Nano 9K of 20K FPGA-board.
4. Open het project in Gowin IDE  ```zx_spectrum_v1.gprj```
5. Verbind de Tang Nano via USB.
6. Programmeerd de FPGA rechtstreeks vanuit Gowin IDE.
7. Sluit de FPGA via HDMI aan op een TV of monitor.
8. Zet het systeem aan en geniet van de ZX Spectrum op echte FPGA!
9. Gebruik de key.py als toetsenbord.

## Magyar (HU)
### Áttekintés

Ez a projekt egy ZX Spectrumot valósít meg Tang Nano 9K FPGA-n. Klasszikus Spectrum BASIC programokat futtat, és támogatja az automatikus gépelést a my_fsm modul segítségével.

### Funkciók

Futtatja a ZX Spectrum BASIC programokat

Typist modul (my_fsm) az automatikus programbevitelhez

HDMI kimenet: 1024x768 @ 24Hz (4x scale), nincs border

Teljes egészében Verilog-ban, a CPU (Z80) kivételével

Videó memória Gowin DPB RAM-mal

Több RAM/ROM blokk támogatása

### Jövőbeli tervek

Billentyűzet támogatás

Tape modul programok mentésére/betöltésére SD kártyáról az eredeti SAVE/LOAD parancsokkal

Hang HDMI-n keresztül

### Használat

1. **Klonozd le a repository-t**  ``` https://github.com/BorsosIstvan/zx_spectrum_v1.git```
2. Telepítsd a Gowin IDE-t (lehetőleg a legújabb verziót).
3. Szerezz be egy Tang Nano 9K vagy 20K FPGA panelt.
4. Nyisd meg a projektet a Gowin IDE-ben  ```zx_spectrum_v1.gprj```
5. Csatlakoztasd a Tang Nano-t USB-n keresztül.
6. Programozd be az FPGA-t közvetlenül a Gowin IDE-ből.
7. Csatlakoztasd a panelt HDMI-n keresztül egy TV-hez vagy monitorhoz.
8. Kapcsold be és élvezd a ZX Spectrum működését valódi FPGA hardveren!
9. Használd a key.py programot billentyűzetnek.
