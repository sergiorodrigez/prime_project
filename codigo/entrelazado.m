function out = entrelazado(bits, M)
    bits_matrix = reshape(bits, length(bits)/M, M);
    out = reshape(bits_matrix', [], 1);
end
