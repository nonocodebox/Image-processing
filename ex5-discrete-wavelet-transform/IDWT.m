function [ image ] = IDWT( waveletDecomp, lowFilt, highFilt, levels )
%IDWT: Converts wavelet coefficients into the original image.
    narginchk(4, 4);
    nargoutchk(0, 1);
    
    try
        % Flip the high filter
        highFilt = fliplr(highFilt);

        % Start with the deepest level
        image = waveletDecomp;
        rows = size(waveletDecomp, 1)/ 2^(levels-1);
        cols = size(waveletDecomp, 2)/ 2^(levels-1);

        for i = levels:-1:1
            % Get the current LL, LH, HL, HH
            LL = image(1:(rows/2), 1:(cols/2));
            LH = image(1:(rows/2), (cols/2+1):cols);  
            HL = image((rows/2+1):rows, 1:(cols/2));
            HH = image((rows/2+1):rows, (cols/2+1):cols);

            % Upsample to get L
            LL = expand(LL, lowFilt', 1);
            LH = expand(LH, highFilt', 1);
            L = LL + LH;

            % Upsample to get H
            HL = expand(HL, lowFilt', 1);
            HH = expand(HH, highFilt', 1);
            H = HL + HH;

            % Upsample to get the next level
            LL_x = expand(L, lowFilt, 0) + expand(H, highFilt, 0);

            image(1: rows, 1:cols) = LL_x;

            rows = rows*2;
            cols = cols*2;
        end
    catch err
        disp(strcat('ERROR: ', err.identifier));
        image = [];
    end
end

