function [pyr, filter] = GaussianPyramid(im, maxLevels, filterSize)
%GaussianPyramid Builds a Gaussian pyramid pyramid, the size of the
% pyramid is not greater than maxLevels.

try
    narginchk(3, 3);
    nargoutchk(0, 2);
    
    pyr =[];
    filter = Create1DGaussianFilter(filterSize);
    gauss_size = sum(size(filter));
    if gauss_size == 0
        return;
    end

    image_size = size(im);
    rows = image_size(1);
    cols = image_size(2);

    % Calculation: c*2^(max-1) / 2^x >= 16 i.e x <= maxLevels -5 + log2(c).
    c = min(rows/(2^(maxLevels-1)), cols/(2^(maxLevels-1)));
    if c == 0
         disp('ERROR: invalid image size.');
         return;
    end

    c = floor(log2(c));
    levels = min(maxLevels -5 + c + 1, maxLevels);
    %plus one is for the place of 16X16

    pyramid  = cell(levels, 1);
    pyramid{1} = im;

    for i = 2:levels
        G_i = Reduce(pyramid{i-1}, filter);
        pyramid{i} = G_i;
    end

    pyr = pyramid;
    
catch err
    disp(strcat('ERROR: ', err.identifier));
    filter = [];
    pyr =[];
    return;
end

end

