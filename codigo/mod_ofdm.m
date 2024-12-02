function out = mod_ofdm(Nfft, Nofdm, Nf, x_mod)
    s = reshape(x_mod, Nf, Nofdm);
    X = zeros(Nfft, Nofdm);
    
    X(88:88+Nf-1,:) = s(1:Nf,:);
    
    X = X+flipud(conj(X));
    
    y_ofdm = ifft(X, Nfft,'symmetric');
    out = reshape(y_ofdm,[],1);
end