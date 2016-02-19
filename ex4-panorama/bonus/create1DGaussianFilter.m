function [ gaussian_filter ] = create1DGaussianFilter(kernelSize)
%createGaussianFilter creates a gaussian filter with kernelSize.

    narginchk(1, 1);
    nargoutchk(0, 1);

    try
        gaussian_filter = [1 1];

        for i = 1:kernelSize-2
            gaussian_filter = conv(gaussian_filter,[1 1]);
        end

        division_factor = sum(gaussian_filter(:));
        gaussian_filter = gaussian_filter / division_factor;

    catch err
        disp(strcat('ERROR: ', err.identifier));
        gaussian_filter = [];
    end

end