# PRIME Communication System Simulation

This project implements a complete end-to-end simulation of a communication system based on the **PRIME (Powerline Intelligent Metering Evolution)** standard, ITU-T G.9904. The system is developed in MATLAB and explores the effects of different modulations, channel conditions, and error correction strategies on the bit error rate (BER).

## Features

- Differential modulations: **DBPSK**, **DQPSK**, and **D8PSK**
- OFDM modulation and demodulation
- Channel model with and without dispersion
- Cyclic prefix and frequency domain equalization
- Optional Forward Error Correction (FEC) using convolutional coding
- Bit randomization and interleaving
- BER vs SNR curve generation and comparison with theoretical performance

## Project Structure

- `mod_todo.m`, `demod_todo.m`: Handle modulation and demodulation processes
- `aleatorizacion.m`, `desaleatorizacion.m`: Bit scrambling and descrambling
- `ecualizacion.m`: Channel equalization
- `entrelazado.m`, `desentrelazado.m`: Interleaving and deinterleaving
- `main_*.m`: Scripts for simulating different communication scenarios (ideal channel, with dispersion, with/without FEC)

## Results

Below are some key results showing the BER performance under various configurations:

### BER in Ideal Channel (no noise, no dispersion)

<img src="https://github.com/user-attachments/assets/63bb1ec7-337b-4bc3-b7fa-586e48995fd0" width="500"/>
<img src="https://github.com/user-attachments/assets/94fce8a4-4ec8-4812-8f8b-c928abc9ed5d" width="500"/>
<img src="https://github.com/user-attachments/assets/e6ebb2aa-8278-4d31-b427-dbc56b0b338d" width="500"/>

### BER with Dispersive Channel and Equalization

<img src="https://github.com/user-attachments/assets/6923db88-7f54-4123-ae44-10e175473716" width="500"/>
<img src="https://github.com/user-attachments/assets/8014821d-5f95-4f00-8a67-65c300ae2296" width="500"/>
<img src="https://github.com/user-attachments/assets/049139ce-9419-4a53-b731-9a0a5c3be3c7" width="500"/>

### BER with FEC (Full System Performance)

<img src="https://github.com/user-attachments/assets/b4dbcf7a-970d-4598-a2ca-ed5cfe60fe9a" width="500"/>
<img src="https://github.com/user-attachments/assets/a88ce6ca-8438-4f48-b85c-e2093a35c046" width="500"/>
<img src="https://github.com/user-attachments/assets/456e1695-aa18-409e-8baf-6fb441768a87" width="500"/>

## How to Run

1. Open MATLAB.
2. Add all `.m` files to your path.
3. Run `main_ideal.m`, `main_channel.m`, or `main_fec.m` depending on the scenario you want to simulate.

## Authors

- Sergio Rodríguez García  
- Miguel Torres Valls: https://github.com/migueltorresvalls

## License

This project is for academic purposes and does not include any license for commercial use.
