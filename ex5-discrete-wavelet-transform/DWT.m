function [ waveletDecomp ] = DWT(image, lowFilt, highFilt, levels)
%DWT: Converts a 2-dimensional discrete signal(image) to its wavelet transform coefficients

    narginchk(4, 4);
    nargoutchk(0, 1);
    
    try
        % First level is the whole image
        waveletDecomp = image;
        rows = size(image, 1);
        cols = size(image, 2);

        for i = 1:levels
            % Get the current level and downsample to get L and H
            input_img = waveletDecomp(1:rows, 1:cols);
            low_cov = reduce(input_img, lowFilt, 0);
            high_cov = reduce(input_img, highFilt, 0);

            % Downsample to get LL, LH, HL, HH
            LL = reduce(low_cov, lowFilt', 1);
            LH = reduce(low_cov, highFilt', 1);
            HL = reduce(high_cov, lowFilt', 1);
            HH = reduce(high_cov, highFilt', 1);

            waveletDecomp(1:(rows/2), 1:(cols/2)) = LL;
            waveletDecomp(1:(rows/2), (cols/2+1):cols) = LH;  
            waveletDecomp((rows/2+1):rows, 1:(cols/2)) = HL;
            waveletDecomp((rows/2+1):rows, (cols/2+1):cols) = HH;

            rows = rows/2;
            cols = cols/2;
        end
    catch err
        disp(strcat('ERROR: ', err.identifier));
        waveletDecomp = [];
    end
end

