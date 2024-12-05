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
% Vectores auxiliares para bucle for
N_tramas = [N_tramas_dbpsk, N_tramas_dqpsk, N_tramas_d8psk];
L_tramas = [N_dbpsk, N_dqpsk, N_d8psk];

Nfft = 512; % Número de puntos fft
Nofdm = 63; % Número de símbolos ofdm
Nf = 96; % Número de subportadoras

% Vector de SNRs
SNR_dB = -5:2:30;
offset_SNR = 10*log10(Nfft/(2*Nf));

% Vectores de BER calculada y BER teórica
BER = zeros(3, length(SNR_dB));
BER_teor = zeros(3, length(SNR_dB));

% Bucle que itera para todas las SNR
for snr=1:length(SNR_dB)
    % Bucle que itera para todas las modulaciones
    for i=1:3
        l_trama = L_tramas(i);
        n_tramas = N_tramas(i);
    
        bits_recibidos = zeros(n_tramas,l_trama);
        bits_transmitidos = zeros(n_tramas,l_trama);
        % Bucle que itera para todas las tramas
        for j=1:n_tramas
            % Si modulación de subportadora es DBPSK
            if i == 1
                [x_ofdm, tx_bits, vector_aleatorizacion] = mod_todo(2, l_trama, Nfft, Nofdm, Nf,0,0);
                
                x_ruido = awgn(x_ofdm, SNR_dB(snr)-offset_SNR,'measured');
                rx_bits = demod_todo(2, x_ruido, Nfft, Nofdm, Nf, vector_aleatorizacion,0,0);
                
            % Si la modulación de subportadora es DQPSK
            elseif i == 2
                [x_ofdm, tx_bits, vector_aleatorizacion] = mod_todo(4, l_trama, Nfft, Nofdm, Nf,0,0);
                
                x_ruido = awgn(x_ofdm, SNR_dB(snr)-offset_SNR,'measured');
                rx_bits = demod_todo(4, x_ruido, Nfft, Nofdm, Nf, vector_aleatorizacion,0,0);
                
            % Si la modulación de subportadora es D8PSK
            elseif i == 3
                [x_ofdm, tx_bits, vector_aleatorizacion] = mod_todo(8, l_trama, Nfft, Nofdm, Nf,0,0);
                
                x_ruido = awgn(x_ofdm, SNR_dB(snr)-offset_SNR,'measured');
                rx_bits = demod_todo(8, x_ruido, Nfft, Nofdm, Nf, vector_aleatorizacion,0,0);
            end
            % Guardo tramas recibidas en una matriz
            bits_recibidos(j,:) = rx_bits;
            bits_transmitidos(j,:) = tx_bits;
        end
        % Concateno filas de la matriz
        bits_recibidos_concatenados = reshape(bits_recibidos,1,N_bits_totales);
        bits_transmitidos_concatenados = reshape(bits_transmitidos,1,N_bits_totales);

        % Cálculo BER para todas las tramas de la modulación
        BER(i,snr) = sum(abs(bits_recibidos_concatenados-bits_transmitidos_concatenados))/N_bits_totales;
        
        % Cálculo BER teórica para todas las tramas de la modulación
        if i == 1
            BER_t = DBPSK_BER(SNR_dB(snr));
        elseif i == 2
            BER_t = DQPSK_BER(SNR_dB(snr));
        elseif i == 3
            BER_t = D8PSK_BER(SNR_dB(snr));
        end
        BER_t(BER_t<1e-5)=NaN;
        BER_teor(i,snr) = BER_t;
    end
end

%% Representación BER vs SNR
figure
semilogy(SNR_dB, BER(1,:))
hold on
semilogy(SNR_dB, BER_teor(1,:))
legend('DBPSK','DBPSK_{teorica}')
ylabel('BER (Bit Error Rate)')
xlabel('SNR (Signal to Noise Relation)')
title('Curvas BER vs SNR')

figure
semilogy(SNR_dB, BER(2,:))
hold on
semilogy(SNR_dB, BER_teor(2,:))
legend('DQPSK','DQPSK_{teorica}')
ylabel('BER (Bit Error Rate)')
xlabel('SNR (Signal to Noise Relation)')
title('Curvas BER vs SNR')

figure
semilogy(SNR_dB, BER(3,:))
hold on
semilogy(SNR_dB, BER_teor(3,:))
legend('D8PSK','D8PSK_{teorica}')
ylabel('BER (Bit Error Rate)')
xlabel('SNR (Signal to Noise Relation)')
title('Curvas BER vs SNR')


%% Expresión algebraica de la señal recibida incluyendo únicamente el efecto del canal
% La señal recibida se calcula como:
% r(t) = s(t) * h(t)
% Donde h(t) es la respuesta al impulso del canal.

% Respuesta al impulso del canal
h = [-0.1 0.3 -0.5 0.7 -0.9 0.7 -0.5 0.3 -0.1];

%% Representación gráfica de la función de transferencia del canal en frecuencia, en dB
Nfft = 512; % Número de puntos para la FFT
H = fft(h, Nfft); % Transformada en frecuencia del canal
H_dB = 20 * log10(abs(H)); % Magnitud en dB
fs = 1/20e-3;
f = ((0:length(H)-1)/length(H)-0.5)*fs;
%f = fs*(Nfft-1);

% Gráfica de la función de transferencia del canal
figure;
plot(f, H_dB);
grid on;
title('Función de transferencia del canal en frecuencia');
xlabel('Frecuencia normalizada');
ylabel('Magnitud (dB)');

%% Inclusión del efecto del canal en el código y obtención de curvas BER sin prefijo cíclico ni ecualización
% Bucle que itera para todas las SNR
for snr=1:length(SNR_dB)
    % Bucle que itera para todas las modulaciones
    for i=1:3
        l_trama = L_tramas(i);
        n_tramas = N_tramas(i);
    
        bits_recibidos = zeros(n_tramas,l_trama);
        bits_transmitidos = zeros(n_tramas,l_trama);
        % Bucle que itera para todas las tramas
        for j=1:n_tramas
            % Si modulación de subportadora es DBPSK
            if i == 1
                [x_ofdm, tx_bits, vector_aleatorizacion] = mod_todo(2, l_trama, Nfft, Nofdm, Nf,0,0);

                % Aplicación del canal
                x_canal = filter(h, 1, x_ofdm); 
                x_ruido = awgn(x_canal, SNR_dB(snr)-offset_SNR,'measured');
                rx_bits = demod_todo(2, x_ruido, Nfft, Nofdm, Nf, vector_aleatorizacion,0,0);
                
            % Si la modulación de subportadora es DQPSK
            elseif i == 2
                [x_ofdm, tx_bits, vector_aleatorizacion] = mod_todo(4, l_trama, Nfft, Nofdm, Nf,0,0);

                % Aplicación del canal
                x_canal = filter(h, 1, x_ofdm); 
                x_ruido = awgn(x_canal, SNR_dB(snr)-offset_SNR,'measured');
                rx_bits = demod_todo(4, x_ruido, Nfft, Nofdm, Nf, vector_aleatorizacion,0,0);
                
            % Si la modulación de subportadora es D8PSK
            elseif i == 3
                [x_ofdm, tx_bits, vector_aleatorizacion] = mod_todo(8, l_trama, Nfft, Nofdm, Nf,0,0);

                % Aplicación del canal
                x_canal = filter(h, 1, x_ofdm); 
                x_ruido = awgn(x_canal, SNR_dB(snr)-offset_SNR,'measured');
                rx_bits = demod_todo(8, x_ruido, Nfft, Nofdm, Nf, vector_aleatorizacion,0,0);
            end
            % Guardo tramas recibidas en una matriz
            bits_recibidos(j,:) = rx_bits;
            bits_transmitidos(j,:) = tx_bits;
        end
        % Concateno filas de la matriz
        bits_recibidos_concatenados = reshape(bits_recibidos,1,N_bits_totales);
        bits_transmitidos_concatenados = reshape(bits_transmitidos,1,N_bits_totales);

        % Cálculo BER para todas las tramas de la modulación
        BER(i,snr) = sum(abs(bits_recibidos_concatenados-bits_transmitidos_concatenados))/N_bits_totales;
        
        % Cálculo BER teórica para todas las tramas de la modulación
        if i == 1
            BER_t = DBPSK_BER(SNR_dB(snr));
        elseif i == 2
            BER_t = DQPSK_BER(SNR_dB(snr));
        elseif i == 3
            BER_t = D8PSK_BER(SNR_dB(snr));
        end
        BER_t(BER_t<1e-5)=NaN;
        BER_teor(i,snr) = BER_t;
    end
end

%% Representación BER vs SNR con canal
figure
semilogy(SNR_dB, BER(1,:))
hold on
semilogy(SNR_dB, BER_teor(1,:))
legend('DBPSK','DBPSK_{teorica}')
ylabel('BER (Bit Error Rate)')
xlabel('SNR (Signal to Noise Relation)')
title('Curvas BER vs SNR con canal')

figure
semilogy(SNR_dB, BER(2,:))
hold on
semilogy(SNR_dB, BER_teor(2,:))
legend('DQPSK','DQPSK_{teorica}')
ylabel('BER (Bit Error Rate)')
xlabel('SNR (Signal to Noise Relation)')
title('Curvas BER vs SNR con canal')

figure
semilogy(SNR_dB, BER(3,:))
hold on
semilogy(SNR_dB, BER_teor(3,:))
legend('D8PSK','D8PSK_{teorica}')
ylabel('BER (Bit Error Rate)')
xlabel('SNR (Signal to Noise Relation)')
title('Curvas BER vs SNR con canal')

%% Inclusión de prefijo cíclico y ecualizador en recepción
Lcp = 16;

% Bucle que itera para todas las SNR
for snr=1:length(SNR_dB)
    % Bucle que itera para todas las modulaciones
    for i=1:3
        l_trama = L_tramas(i);
        n_tramas = N_tramas(i);
    
        bits_recibidos = zeros(n_tramas,l_trama);
        bits_transmitidos = zeros(n_tramas,l_trama);
        % Bucle que itera para todas las tramas
        for j=1:n_tramas
            % Si modulación de subportadora es DBPSK
            if i == 1
                [x_ofdm, tx_bits, vector_aleatorizacion] = mod_todo(2, l_trama, Nfft, Nofdm, Nf,1,Lcp);

                % Aplicación del canal
                x_canal = filter(h, 1, x_ofdm); 
                x_ruido = awgn(x_canal, SNR_dB(snr)-offset_SNR,'measured');

                % Ecualizacion
                
                rx_bits = demod_todo(2, x_ruido, Nfft, Nofdm, Nf, vector_aleatorizacion,1,Lcp);
                
            % Si la modulación de subportadora es DQPSK
            elseif i == 2
                [x_ofdm, tx_bits, vector_aleatorizacion] = mod_todo(4, l_trama, Nfft, Nofdm, Nf,1,Lcp);

                % Aplicación del canal
                x_canal = filter(h, 1, x_ofdm); 
                x_ruido = awgn(x_canal, SNR_dB(snr)-offset_SNR,'measured');

                % Ecualizacion

                rx_bits = demod_todo(4, x_ruido, Nfft, Nofdm, Nf, vector_aleatorizacion,1,Lcp);
                
            % Si la modulación de subportadora es D8PSK
            elseif i == 3
                [x_ofdm, tx_bits, vector_aleatorizacion] = mod_todo(8, l_trama, Nfft, Nofdm, Nf,1,Lcp);

                % Aplicación del canal
                x_canal = filter(h, 1, x_ofdm); 
                x_ruido = awgn(x_canal, SNR_dB(snr)-offset_SNR,'measured');

                % Ecualizacion

                rx_bits = demod_todo(8, x_ruido, Nfft, Nofdm, Nf, vector_aleatorizacion,1,Lcp);
            end
            % Guardo tramas recibidas en una matriz
            bits_recibidos(j,:) = rx_bits;
            bits_transmitidos(j,:) = tx_bits;
        end
        % Concateno filas de la matriz
        bits_recibidos_concatenados = reshape(bits_recibidos,1,N_bits_totales);
        bits_transmitidos_concatenados = reshape(bits_transmitidos,1,N_bits_totales);

        % Cálculo BER para todas las tramas de la modulación
        BER(i,snr) = sum(abs(bits_recibidos_concatenados-bits_transmitidos_concatenados))/N_bits_totales;
        
        % Cálculo BER teórica para todas las tramas de la modulación
        if i == 1
            BER_t = DBPSK_BER(SNR_dB(snr));
        elseif i == 2
            BER_t = DQPSK_BER(SNR_dB(snr));
        elseif i == 3
            BER_t = D8PSK_BER(SNR_dB(snr));
        end
        BER_t(BER_t<1e-5)=NaN;
        BER_teor(i,snr) = BER_t;
    end
end


%% Representación BER vs SNR con canal y ecualizacion
figure
semilogy(SNR_dB, BER(1,:))
hold on
semilogy(SNR_dB, BER_teor(1,:))
legend('DBPSK','DBPSK_{teorica}')
ylabel('BER (Bit Error Rate)')
xlabel('SNR (Signal to Noise Relation)')
title('Curvas BER vs SNR con canal')

figure
semilogy(SNR_dB, BER(2,:))
hold on
semilogy(SNR_dB, BER_teor(2,:))
legend('DQPSK','DQPSK_{teorica}')
ylabel('BER (Bit Error Rate)')
xlabel('SNR (Signal to Noise Relation)')
title('Curvas BER vs SNR con canal')

figure
semilogy(SNR_dB, BER(3,:))
hold on
semilogy(SNR_dB, BER_teor(3,:))
legend('D8PSK','D8PSK_{teorica}')
ylabel('BER (Bit Error Rate)')
xlabel('SNR (Signal to Noise Relation)')
title('Curvas BER vs SNR con canal ecualizado')

