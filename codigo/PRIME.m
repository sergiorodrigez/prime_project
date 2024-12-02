%% Proyecto PRIME
clear all
clc
%% Modulaciones
% Número de símbolos ofdm. Igual para todas las modulaciones
M = 63; 

%d8psk
N_d8psk = 288*M;
% Fijamos número de tramas d8psk a 2
N_tramas_d8psk = 2;
N_bits_totales = N_d8psk*N_tramas_d8psk;

% dbpsk
N_dbpsk = 96*M;
N_tramas_dbpsk = ceil(N_bits_totales/N_dbpsk);


%dqpsk
N_dqpsk = 192*M;
N_tramas_dqpsk = ceil(N_bits_totales/N_dqpsk);

%% Cálculo BER
% Funciones demodulaciones
N_tramas = [N_tramas_dbpsk, N_tramas_dqpsk, N_tramas_d8psk];
L_tramas = [N_dbpsk, N_dqpsk, N_d8psk];

Nfft = 512; % Número de puntos fft
Nofdm = 63; % Número de símbolos ofdm
Nf = 96; % Número de subportadoras

SNR_dB = -20:5:40;
BER = zeros(3, length(SNR_dB));

for snr=1:length(SNR_dB)
    for i=1:3
        l_trama = L_tramas(i);
        n_tramas = N_tramas(i);
    
        bits_recibidos = zeros(n_tramas,l_trama);
        bits_transmitidos = zeros(n_tramas,l_trama);
        for j=1:n_tramas
            % Función modulación y demodulación
            if i == 1
                tx_bits = randi([0,1],N_dbpsk,1);
                %tx_aletorio, vector_aleatorizacion = aleatorizacion(tx_bits);
                x_mod = mod_dbpsk(tx_bits);
                x_ofdm = mod_ofdm(Nfft,Nofdm,Nf,x_mod);
                x_ruido = awgn(x_ofdm, SNR_dB(snr),'measured');
                y_ofdm = demod_ofdm(x_ruido,Nfft,Nf,Nofdm);

                dbpsk_demod = comm.DPSKDemodulator(2,0,'BitOutput',true);
                rx_bits = dbpsk_demod(y_ofdm);
            elseif i == 2
                tx_bits = randi([0,1],N_dqpsk,1);
                x_mod = mod_dqpsk(tx_bits);
                x_ofdm = mod_ofdm(Nfft,Nofdm,Nf,x_mod);
                x_ruido = awgn(x_ofdm, SNR_dB(snr),'measured');
                y_ofdm = demod_ofdm(x_ruido,Nfft,Nf,Nofdm);

                dqpsk_demod = comm.DPSKDemodulator(4,0,'BitOutput',true);
                rx_bits = dqpsk_demod(y_ofdm);
            elseif i == 3
                tx_bits = randi([0,1],N_d8psk,1);
                x_mod = mod_d8psk(tx_bits);
                x_ofdm = mod_ofdm(Nfft,Nofdm,Nf,x_mod);
                x_ruido = awgn(x_ofdm, SNR_dB(snr),'measured');
                y_ofdm = demod_ofdm(x_ruido,Nfft,Nf,Nofdm);

                d8psk_demod = comm.DPSKDemodulator(8,0,'BitOutput',true);
                rx_bits = d8psk_demod(y_ofdm);
            end
            % Concateno
            bits_recibidos(j,:) = rx_bits;
            bits_transmitidos(j,:) = tx_bits;
        end
        bits_recibidos_concatenados = reshape(bits_recibidos,1,N_bits_totales);
        bits_transmitidos_concatenados = reshape(bits_transmitidos,1,N_bits_totales);

        BER(i,snr) = sum(abs(bits_recibidos_concatenados-bits_transmitidos_concatenados))/N_bits_totales;
    end
end

%% Añadimos aleatorización y desaleatorización
bits_aleatorios = [0 0 0 0 1 1 1 0 1 1 1 1 0 0 1 0 1 1 0 0 1 0 0 1 0 0 0 0 0 0 1 0 0 0 1 0 0 1 1 0 0 0 1 0 1 1 1 0 1 0 1 1 0 1 1 0 0 0 0 0 1 1 0 0 1 1 0 1 0 1 0 0 1 1 1 0 0 1 1 1 1 0 1 1 0 1 0 0 0 0 1 0 1 0 1 0 1 1 1 1 1 0 1 0 0 1 0 1 0 0 0 1 1 0 1 1 1 0 0 0 1 1 1 1 1 1 1];
repeticiones_bits_aleatorios = length(tx_bits)/length(bits_aleatorios);
vector_aleatorizacion = repmat(bits_aleatorios, ceil(repeticiones_bits_aleatorios));
vector_aleatorizacion = vector_aleatorizacion(1:length(tx_bits));

%% Calculamos curvas BER vs SNR
semilogy(SNR_dB, BER(1,:))
hold on
semilogy(SNR_dB, BER(2,:))
semilogy(SNR_dB, BER(3,:))
legend('DBPSK','DQPSK','D8PSK')
ylabel('BER (Bit Error Rate)')
xlabel('SNR (Signal to Noise Relation)')
title('Curvas BER vs SNR')

%% Proyecto PRIME: Ejercicio 3 - Canal y Ecualización

%% 1. Expresión algebraica de la señal recibida incluyendo únicamente el efecto del canal
% La señal recibida se calcula como:
% r(t) = s(t) * h(t)
% Donde h(t) es la respuesta al impulso del canal.

% Respuesta al impulso del canal
h = [-0.1 0.3 -0.5 0.7 -0.9 0.7 -0.5 0.3 -0.1];

%% 2. Representación gráfica de la función de transferencia del canal en frecuencia, en dB
Nfft = 512; % Número de puntos para la FFT
H = fft(h, Nfft); % Transformada en frecuencia del canal
H_dB = 20 * log10(abs(H)); % Magnitud en dB
f = (0:Nfft-1) / Nfft; % Frecuencia normalizada

% Gráfica de la función de transferencia del canal
figure;
plot(f, H_dB);
grid on;
title('Función de transferencia del canal en frecuencia');
xlabel('Frecuencia normalizada');
ylabel('Magnitud (dB)');

%% 3. Inclusión del efecto del canal en el código y obtención de curvas BER sin prefijo cíclico ni ecualización
% Inicialización
SNR_dB = -20:5:40;
N_dbpsk = 96 * 63;
N_dqpsk = 192 * 63;
N_d8psk = 288 * 63;
N_tramas_d8psk = 2;
N_bits_totales = N_d8psk * N_tramas_d8psk;
N_tramas = [ceil(N_bits_totales / N_dbpsk), ceil(N_bits_totales / N_dqpsk), N_tramas_d8psk];
L_tramas = [N_dbpsk, N_dqpsk, N_d8psk];
BER_canal_sin_ecualizar = zeros(3, length(SNR_dB));

for snr = 1:length(SNR_dB)
    for i = 1:3
        l_trama = L_tramas(i);
        n_tramas = N_tramas(i);
    
        bits_recibidos = zeros(n_tramas, l_trama);
        bits_transmitidos = zeros(n_tramas, l_trama);
        for j = 1:n_tramas
            % Generación de bits y modulación
            if i == 1
                tx_bits = randi([0, 1], N_dbpsk, 1);
                x_mod = mod_dbpsk(tx_bits);
            elseif i == 2
                tx_bits = randi([0, 1], N_dqpsk, 1);
                x_mod = mod_dqpsk(tx_bits);
            elseif i == 3
                tx_bits = randi([0, 1], N_d8psk, 1);
                x_mod = mod_d8psk(tx_bits);
            end
            
            % Modulación OFDM y aplicación del canal
            x_ofdm = mod_ofdm(Nfft, 63, 96, x_mod);
            x_canal = filter(h, 1, x_ofdm); % Aplicación del canal
            x_ruido = awgn(x_canal, SNR_dB(snr), 'measured'); % Ruido AWGN
            
            % Demodulación OFDM
            y_ofdm = demod_ofdm(x_ruido, Nfft, 96, 63);
            
            % Demodulación según el tipo de modulación
            if i == 1
                dbpsk_demod = comm.DPSKDemodulator(2, 0, 'BitOutput', true);
                rx_bits = dbpsk_demod(y_ofdm);
            elseif i == 2
                dqpsk_demod = comm.DPSKDemodulator(4, 0, 'BitOutput', true);
                rx_bits = dqpsk_demod(y_ofdm);
            elseif i == 3
                d8psk_demod = comm.DPSKDemodulator(8, 0, 'BitOutput', true);
                rx_bits = d8psk_demod(y_ofdm);
            end
            
            % Registro de bits transmitidos y recibidos
            bits_recibidos(j, :) = rx_bits;
            bits_transmitidos(j, :) = tx_bits;
        end
        
        % Calcular BER
        bits_recibidos_concatenados = reshape(bits_recibidos, 1, []);
        bits_transmitidos_concatenados = reshape(bits_transmitidos, 1, []);
        BER_canal_sin_ecualizar(i, snr) = sum(abs(bits_recibidos_concatenados - bits_transmitidos_concatenados)) / N_bits_totales;
    end
end

%% Gráficas de BER
figure;
semilogy(SNR_dB, BER_canal_sin_ecualizar(1, :), '-o');
hold on;
semilogy(SNR_dB, BER_canal_sin_ecualizar(2, :), '-s');
semilogy(SNR_dB, BER_canal_sin_ecualizar(3, :), '-d');
legend('DBPSK sin ecualizar', 'DQPSK sin ecualizar', 'D8PSK sin ecualizar');
grid on;
xlabel('SNR (dB)');
ylabel('BER');
title('Curvas BER vs SNR sin ecualización');

%% 4. Inclusión de prefijo cíclico y ecualizador en recepción
% Parámetros del prefijo cíclico
L_cp = 16; % Longitud del prefijo cíclico
BER_canal_ecualizado = zeros(3, length(SNR_dB));

for snr = 1:length(SNR_dB)
    for i = 1:3
        l_trama = L_tramas(i);
        n_tramas = N_tramas(i);

        bits_recibidos = zeros(n_tramas, l_trama);
        bits_transmitidos = zeros(n_tramas, l_trama);
        for j = 1:n_tramas
            % Generación de bits y modulación
            if i == 1
                tx_bits = randi([0, 1], N_dbpsk, 1);
                x_mod = mod_dbpsk(tx_bits);
            elseif i == 2
                tx_bits = randi([0, 1], N_dqpsk, 1);
                x_mod = mod_dqpsk(tx_bits);
            elseif i == 3
                tx_bits = randi([0, 1], N_d8psk, 1);
                x_mod = mod_d8psk(tx_bits);
            end
            
            % Modulación OFDM con prefijo cíclico
            x_ofdm_cp = mod_ofdm_cp(Nfft, 63, 96, L_cp, x_mod);
            x_canal = filter(h, 1, x_ofdm_cp); % Aplicación del canal
            x_ruido = awgn(x_canal, SNR_dB(snr), 'measured'); % Ruido AWGN
            
            % Demodulación OFDM con prefijo cíclico y ecualización
            y_ofdm_cp = demod_ofdm_cp(x_ruido, Nfft, 96, 63, L_cp);
            H_estimado = fft(h, 96); % Usar piloto para estimar el canal
            y_ecualizado = y_ofdm_cp ./ H_estimado; % Ecualización
            
            % Demodulación según el tipo de modulación
            if i == 1
                dbpsk_demod = comm.DPSKDemodulator(2, 0, 'BitOutput', true);
                rx_bits = dbpsk_demod(y_ecualizado(:));
            elseif i == 2
                dqpsk_demod = comm.DPSKDemodulator(4, 0, 'BitOutput', true);
                rx_bits = dqpsk_demod(y_ecualizado(:));
            elseif i == 3
                d8psk_demod = comm.DPSKDemodulator(8, 0, 'BitOutput', true);
                rx_bits = d8psk_demod(y_ecualizado(:));
            end

            % Registro de bits transmitidos y recibidos
            % Registro de bits transmitidos y recibidos
            bits_recibidos(j, :) = rx_bits(1:l_trama); % Truncar si rx_bits tiene más elementos
            bits_transmitidos(j, :) = tx_bits(1:l_trama); % Asegura que tx_bits también coincida

        end
        
        % Calcular BER
        bits_recibidos_concatenados = reshape(bits_recibidos, 1, []);
        bits_transmitidos_concatenados = reshape(bits_transmitidos, 1, []);
        BER_canal_ecualizado(i, snr) = sum(abs(bits_recibidos_concatenados - bits_transmitidos_concatenados)) / N_bits_totales;
    end
end

%% Gráficas de BER
figure;
semilogy(SNR_dB, BER_canal_sin_ecualizar(1, :), '-o');
hold on;
semilogy(SNR_dB, BER_canal_sin_ecualizar(2, :), '-s');
semilogy(SNR_dB, BER_canal_sin_ecualizar(3, :), '-d');
semilogy(SNR_dB, BER_canal_ecualizado(1, :), '--o');
semilogy(SNR_dB, BER_canal_ecualizado(2, :), '--s');
semilogy(SNR_dB, BER_canal_ecualizado(3, :), '--d');
legend('DBPSK sin ecualizar', 'DQPSK sin ecualizar', 'D8PSK sin ecualizar', ...
       'DBPSK ecualizado', 'DQPSK ecualizado', 'D8PSK ecualizado');
grid on;
xlabel('SNR (dB)');
ylabel('BER');
title('Curvas BER vs SNR con y sin ecualización');

