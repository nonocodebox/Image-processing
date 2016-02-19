function [ signal ] = IDFT( fourierSignal )
%IDFT Revereses 1D fourier transform into signal space.

narginchk(1, 1);
nargoutchk(0, 1);

try
    sig_size = size(fourierSignal);
    N = sig_size(2);

    w = exp((2*pi*1i)/N);
    w_vec = repmat(w, 1, N);
    pow = 0:N-1;
    base = w_vec.^ pow;

    vander_mat = fliplr(vander(base));
    signal = ((1/N) * (vander_mat * (fourierSignal.')).');
    
catch err
    disp(strcat('ERROR: ', err.identifier));
    signal = [];
    return;
end
end