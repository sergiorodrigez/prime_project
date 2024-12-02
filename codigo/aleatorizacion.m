function [bits_out, vector_aleatorizacion] = aleatorizacion(bits_in)
bits_aleatorios = [0 0 0 0 1 1 1 0 1 1 1 1 0 0 1 0 1 1 0 0 1 0 0 1 0 0 0 0 0 0 1 0 0 0 1 0 0 1 1 0 0 0 1 0 1 1 1 0 1 0 1 1 0 1 1 0 0 0 0 0 1 1 0 0 1 1 0 1 0 1 0 0 1 1 1 0 0 1 1 1 1 0 1 1 0 1 0 0 0 0 1 0 1 0 1 0 1 1 1 1 1 0 1 0 0 1 0 1 0 0 0 1 1 0 1 1 1 0 0 0 1 1 1 1 1 1 1];
repeticiones_bits_aleatorios = length(bits_in)/length(bits_aleatorios);
vector_aleatorizacion = repmat(bits_aleatorios, ceil(repeticiones_bits_aleatorios));

vector_aleatorizacion = vector_aleatorizacion(1:length(tx_bits));
bits_out = xor(bits_in, vector_aleatorizacion);
end