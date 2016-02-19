function [ fourierImage ] = DFT2( image )
%DFT2 2D DFT uning matrix multipcation by multiply each colum and then
% each row with a vander matrix.

narginchk(1, 1);
nargoutchk(0, 1);

try
    fourierImage = DFT((DFT(image.')).');
    
catch err
    disp(strcat('ERROR: ', err.identifier));
    fourierImage = [];
end
end

