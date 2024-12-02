function out = demod_ofdm_cp(x_rx, Nfft, Nf, Nofdm, L_cp)
    x_rx = reshape(x_rx, Nfft+L_cp, Nofdm);
    x_rx = x_rx(L_cp+1:end, :); % Eliminar prefijo cíclico
    x = fft(x_rx, Nfft);
    x_mod = x(88:88+Nf-1, :);
    out = reshape(x_mod, [], 1);
end