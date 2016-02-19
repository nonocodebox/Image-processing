function [ magnitude ] = fourierDerivative( inImage )
%fourierDerivative derives an image in fourier space.

narginchk(1, 1);
nargoutchk(0, 1);

try
    % first we center the image in fourier space, multiply with the frequency
    % and then de-center in order to return to the default representation (before returning to image space).
    fourier_img = DFT2(inImage);
    fourier_img_shift = fftshift(fourier_img);

    image_size = size(inImage);
    rows = image_size(1);
    cols = image_size(2);

    constant = 2*pi*1i;
    const_x = constant / cols;
    const_y = constant / rows;

    u = repmat([ceil(-cols/2): (ceil(cols/2) -1)], rows, 1);
    v = repmat([ceil(-rows/2): (ceil(rows/2) -1)]', 1, cols);

    centered_dervX = fourier_img_shift .* u .* const_x;
    centered_dervY = fourier_img_shift .* v .* const_y;

    derivative_x = IDFT2(ifftshift(centered_dervX));
    derivative_y = IDFT2(ifftshift(centered_dervY));

    magnitude = real(sqrt(derivative_x.^2 + derivative_y.^2));

catch err
    disp(strcat('ERROR: ', err.identifier));
    magnitude = [];
end

imshow(magnitude);

end