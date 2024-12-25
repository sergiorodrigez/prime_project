function out = desentrelazado(bits, M)
    bits_matrix = reshape(bits, M, length(bits)/M);
    out = reshape(bits_matrix', [], 1);
end
