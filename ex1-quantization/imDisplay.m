function [ ] = imDisplay( filename, representation )
%imDisplay Displays a picture retured from imReadAndConvert 
%   with cordinates and pixel intensity information.

% Read the image and convert to the representation
im = imReadAndConvert( filename, representation );

% Show the image
figure;
handle = imshow(im);

% Show pixel info on the figure
impixelinfo(handle);
end

