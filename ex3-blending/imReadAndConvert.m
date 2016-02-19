function [ img ] = imReadAndConvert( filename, representation )
    %imReadAndConvert this function converts RGB image to grayscale.
    % 1 indecates a grayscale image, 2 inducates a RGB image.     
try
    if exist(filename, 'file') == 0
       disp('ERROR: invalid path.');
       return;
    end
    
    if representation ~= 1 && representation ~= 2
        disp('ERROR: invalid representation arrgument.');
       return;
    end
    
    arg_im = imread(filename);
    arg_im = double(arg_im)/255;
    img = arg_im;
    
    info = imfinfo(filename);
    if (strcmp(info.ColorType, 'truecolor') && representation == 2) || ...
        (strcmp(info.ColorType, 'grayscale') && representation == 1) || ...
        (strcmp(info.ColorType, 'grayscale') && representation == 2)
        % Assuming no conversions from graysale to RGB will be requested.
        return;
    end
    
    if strcmp(info.ColorType, 'truecolor')
        img = rgb2gray(arg_im);
    end
    
catch err
    disp(strcat('ERROR: ', err.identifier));
    img = [];
end

end