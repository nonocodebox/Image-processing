function [ res ] = renderPyramid(pyr, levels)
%renderPyramid Builds a pyramid display with a given number of levels.
try
    res = [];
    
    narginchk(2, 2);
    nargoutchk(0, 1);
    
    pyr_size = size(pyr);
    
    if levels > pyr_size(1)
        disp('ERROR: invalid level count.');
        return;
    end
    
    image_size = size(pyr{1});
    rows = image_size(1);
    cols = image_size(2);

    % calculate the number of colums in res.
    y_sizes = cols ./ (2 .^ (0 : levels-1));
    y_axis = sum(y_sizes);

    display_img = ones(rows, y_axis);

    % place the first image in the pyramid.
    image_size = size(pyr{1});
    rows = image_size(1);
    cols = image_size(2);
    display_img(1: rows, 1: cols) = pyr{1};

    last_col = cols;

    for i = 2:levels
        image_size = size(pyr{i});
        rows = image_size(1);
        cols = image_size(2);

        display_img(1:rows, (last_col + 1) : (last_col + cols)) = pyr{i};

        last_col = last_col + cols; 
    end

    res = display_img;
    
catch err
    disp(strcat('ERROR: ', err.identifier));
    res = [];
    return;
end


