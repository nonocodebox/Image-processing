function [ fourierSignal ] = DFT( signal )
%DFT Transforms 1D signal to Fourier 1D base.
% signal is a row vector.

narginchk(1, 1);
nargoutchk(0, 1);

try
    sig_size = size(signal);
    N = sig_size(2);

    w = exp((-2*pi*1i)/N);
    w_vec = repmat(w, 1, N);
    pow = 0:N-1;
    base = w_vec.^ pow;

    vander_mat = fliplr(vander(base));
    fourierSignal = (vander_mat * double(signal).').';
    
catch err
    disp(strcat('ERROR: ', err.identifier));
    fourierSignal = [];
    return;
end

end

