function [ denoisImage ] = denoising(image, lowFilt, highFilt, levels)
%denoising Denoises an image using DWT

    narginchk(4, 4);
    nargoutchk(0, 1);
    
    try
        THRESHOLD = 0.022;

        waveletDecomp = DWT(image, lowFilt, highFilt, levels);

        % Save LL
        LLrows = size(waveletDecomp, 1)/ 2^(levels-1);
        LLcols = size(waveletDecomp, 2)/ 2^(levels-1);
        LL = waveletDecomp(1:(LLrows/2), 1:(LLcols/2));

        % Zero values smaller than the threshold
        waveletDecomp = (abs(waveletDecomp) > THRESHOLD) .* waveletDecomp;

        % Restore LL
        waveletDecomp(1:(LLrows/2), 1:(LLcols/2)) = LL;

        denoisImage = IDWT(waveletDecomp, lowFilt, highFilt, levels);

        figure; subplot(1,2,1); imshow(image);title('Noisy');
        subplot(1,2,2); imshow(denoisImage);title('Denoised');
    catch err
        disp(strcat('ERROR: ', err.identifier));
        denoisImage = [];
    end
end

