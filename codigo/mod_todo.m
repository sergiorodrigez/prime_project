function [x_ofdm, tx_bits, vector_aleatorizacion] = mod_todo(M, L_trama, Nfft, Nofdm, Nf, PrefijoCiclico, Lcp)
if M == 2
    tx_bits = randi([0,1],L_trama,1);
    [tx_aleatorio, vector_aleatorizacion] = aleatorizacion(tx_bits);
    x_mod = mod_dbpsk(tx_aleatorio);
elseif M == 4
    tx_bits = randi([0,1],L_trama,1);
    [tx_aleatorio, vector_aleatorizacion] = aleatorizacion(tx_bits);
    x_mod = mod_dqpsk(tx_aleatorio);
elseif M == 8
    tx_bits = randi([0,1],L_trama,1);
    [tx_aleatorio, vector_aleatorizacion] = aleatorizacion(tx_bits);
    x_mod = mod_d8psk(tx_aleatorio);
end
if PrefijoCiclico == 0
    x_ofdm = mod_ofdm(Nfft,Nofdm,Nf,x_mod);
else 
    x_ofdm = mod_ofdm_cp(Nfft,Nofdm,Nf,Lcp,x_mod);
end