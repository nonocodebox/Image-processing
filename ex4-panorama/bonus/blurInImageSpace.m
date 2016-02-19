function [ blurImage ] = blurInImageSpace( inImage, kernelSize )
%blurInImageSpace blurs an image with a gaussian convolution. 

    narginchk(2, 2);
    nargoutchk(0, 1);

    try
        gaussian_filter = create1DGaussianFilter(kernelSize);
        blurImage = [];

        gauss_size = sum(size(gaussian_filter));
        if gauss_size == 0
            imshow(blurImage);
            return;
        end

        if numel(inImage) <= kernelSize^2
            disp(strcat('ERROR: kernel size is too big.'));
            return;
        end

        blurImage = conv2(inImage, gaussian_filter, 'same');

    catch err
        disp(strcat('ERROR: ', err.identifier));
        blurImage = [];
    end

end

