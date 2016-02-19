function [ outImage ] = deleteHorizontal(image, lowFilt, highFilt, levels)
%deleteHorizontal Deletes horizontal lines from an image

    narginchk(4, 4);
    nargoutchk(0, 1);
    
    try
        waveletDecomp = DWT(image, lowFilt, highFilt, levels);

        rows = size(waveletDecomp, 1)/ 2^(levels-1);
        cols = size(waveletDecomp, 2)/ 2^(levels-1);

        for i = levels:-1:1
            waveletDecomp(1:(rows/2), (cols/2+1):cols) = 0; %Set LH to zero

            rows = rows*2;
            cols = cols*2;
        end

        outImage = IDWT( waveletDecomp, lowFilt, highFilt, levels);

        imshow(outImage);
        
    catch err
        disp(strcat('ERROR: ', err.identifier));
        outImage = [];
    end
end
