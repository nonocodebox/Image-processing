function [ gaussian_filter ] = createGaussianFilter( kernelSize )
%createGaussianFilter creates a gaussian filter with kernelSize.

narginchk(1, 1);
nargoutchk(0, 1);

try
    gaussian_filter = [];
    if mod(kernelSize,2) == 0
        disp(strcat('ERROR: kernel size is not odd.'));
        return;
    end

    if kernelSize == 1
        gaussian_filter = 1;
        return;
    end
    
    binomial_size = floor(kernelSize/ 2)*2;
    coeff = [1 1];
    for i = 1:binomial_size-1
        coeff = conv(coeff,[1 1]);
    end

    gaussian_filter = conv2(coeff, coeff.');
    division_factor = sum(gaussian_filter(:));

    gaussian_filter = gaussian_filter / division_factor;
    
catch err
    disp(strcat('ERROR: ', err.identifier));
    gaussian_filter = [];
    return;
end

end

