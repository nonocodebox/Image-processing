function [  ] = displayPyramid(pyr, levels)
%displayPyramid Displays renderPyramid's output.
try
    narginchk(2, 2);
    nargoutchk(0, 0);
    
    figure; imshow(renderPyramid(pyr, levels)); 
    
catch err
    disp(strcat('ERROR: ', err.identifier)); 
end

end

