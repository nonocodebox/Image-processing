function [ blurImage ] = blurInFourierSpace( inImage, kernelSize )
%blurInFourierSpace blurs an image with a gaussian in fourier space.

narginchk(2, 2);
nargoutchk(0, 1);

kernel = createGaussianFilter(kernelSize);
blurImage = [];

gauss_size = sum(size(kernel));
if gauss_size == 0
    imshow(blurImage);
    return;
end

if numel(inImage) <= kernelSize^2
    disp(strcat('ERROR: kernel size is too big.'));
    imshow(blurImage);
    return;
end

try
    image_size = size(inImage);
    rows = image_size(1);
    cols = image_size(2);

    % Padding the gaussian with zeros in order to be able to multiply matrices. 
    zero_padding = zeros(rows, cols);
    center_x = floor(rows/2) + 1;
    center_y = floor(cols/2) + 1;

    from_x = center_x - floor(kernelSize/2);
    to_x = center_x + floor(kernelSize/2);
    
    from_y = center_y - floor(kernelSize/2);
    to_y = center_y + floor(kernelSize/2);
    
    % Put gaussian filter in the center of the big zeroed matrix.
    zero_padding([from_x:to_x], [from_y:to_y]) = kernel;
    
    G = DFT2(ifftshift(zero_padding));
    F = DFT2(inImage);

    fourier_blur = F.*G;

    blurImage = real(IDFT2(fourier_blur));
    
catch err
    disp(strcat('ERROR: ', err.identifier));
    blurImage = [];
end

imshow(blurImage);

end