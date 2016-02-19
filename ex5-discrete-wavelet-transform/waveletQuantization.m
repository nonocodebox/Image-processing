function [compressedImage, waveletDecompCompressed] = waveletQuantization(image,lowFilt,highFilt,levels,nQuant)
%waveletQuantization Performs quantization of the wavelet details
%coefficients

    narginchk(5, 5);
    nargoutchk(0, 2);
    
    try
        ITERATIONS = 8;

        waveletDecomp = DWT(image, lowFilt, highFilt, levels);

        waveletDecompCompressed = waveletDecomp;
        rows = size(waveletDecomp, 1)/ 2^(levels-1);
        cols = size(waveletDecomp, 2)/ 2^(levels-1);

        LLrows = 1:(rows/2);
        LLcols = 1:(cols/2);

        waveletDecompCompressed(LLrows, LLcols) = max(waveletDecomp(:));
        minVal = min(waveletDecompCompressed(:));

        % Shift to the range 0..1 for saving
        waveletDecompShifted = waveletDecomp + 0.5;
        waveletDecompShifted(LLrows, LLcols) = waveletDecomp(LLrows, LLcols);

        % Save the image before compression
        waveletInt = uint8(round(waveletDecompShifted * 255.0));
        save('beforeCompress.mat', 'waveletInt', '-v6');
        gzip('beforeCompress.mat');

        % Shift again, but this time by the minumum value for quantization
        waveletDecompShifted = waveletDecomp - minVal;
        waveletDecompShifted(LLrows, LLcols) = waveletDecomp(LLrows, LLcols);

        % Quantize the image
        waveletDecompCompressedShifted = quantizeImage(waveletDecompShifted, nQuant, ITERATIONS, LLrows, LLcols);

        % Shift back to the normal range
        waveletDecompCompressed = waveletDecompCompressedShifted + minVal;
        waveletDecompCompressed(LLrows, LLcols) = waveletDecompCompressedShifted(LLrows, LLcols);

        % Shift to the range 0..1 for saving
        waveletDecompCompressedShifted = waveletDecompCompressed + 0.5;
        waveletDecompCompressedShifted(LLrows, LLcols) = waveletDecompCompressed(LLrows, LLcols);

        % Save the image after compression
        compressedInt = uint8(round(waveletDecompCompressedShifted * 255.0));
        save('afterCompress.mat', 'compressedInt', '-v6');
        gzip('afterCompress.mat');

        compressedImage = IDWT(waveletDecompCompressed, lowFilt, highFilt, levels);

        imshow(compressedImage);
    catch err
        disp(strcat('ERROR: ', err.identifier));
        compressedImage = [];
        waveletDecompCompressed = [];
    end
end

