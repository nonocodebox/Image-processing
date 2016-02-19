function [ strip_corners, right ] = calculatePanoramicBorders( imgs, T, panoramaSize, imgSliceCenterX, halfSliceWidthX )
%calculatePanoramicBorders Calculates the borders (corners) of the panorama
% strips, given the imges, transformations, panorama size and slice centers.

    narginchk(5, 5);
    nargoutchk(0, 2);
    
    try
        nfiles = size(imgs, 4);
        centers = zeros(1, nfiles);
        right = false;
        strip_corners = zeros(2, 4, nfiles);
        
        % Calculate the slice centers in panorama coordinates.
        for i = 1:nfiles
            center = T{i} * [imgSliceCenterX(i) ; 0 ; 1];
            centers(i) = center(1);
        end

        % Check if we are moving right.
        if centers(nfiles) - centers(1) > 0
            right = true;
        end
        
        height = panoramaSize(1);
        
        for i = 1:nfiles
            % Calculate the slice corners in panorama coordinates
            if i == 1 && right
                corner1 = [ centers(i) - halfSliceWidthX ; 1 ; 1];
                corner2 = [(centers(i) + centers(i + 1)) / 2 ; height ; 1];
            elseif i == 1 && not(right)
                corner1 = [ centers(i) + halfSliceWidthX ; 1 ; 1];
                corner2 = [(centers(i) + centers(i + 1)) / 2 ; height ; 1];
            elseif i == nfiles && right
                corner1 = [(centers(i-1) + centers(i)) / 2 ; 1 ; 1];
                corner2 = [centers(i) +  halfSliceWidthX; height ; 1];
            elseif i == nfiles && not(right)
                corner1 = [(centers(i-1) + centers(i)) / 2 ; 1 ; 1];
                corner2 = [centers(i) -  halfSliceWidthX; height ; 1];
            else
                corner1 = [(centers(i-1) + centers(i)) / 2 ; 1 ; 1];
                corner2 = [(centers(i) + centers(i + 1)) / 2 ; height ; 1];
            end
            
            % Transform the panorama corners to MATLAB format (y, x) and
            % calculate the other two corners
            strip_corners(:, 1, i) = [corner1(2) corner1(1)]; % TL
            strip_corners(:, 2, i) = [corner1(2) corner2(1)]; % TR
            strip_corners(:, 3, i) = [corner2(2) corner2(1)]; % BR
            strip_corners(:, 4, i) = [corner2(2) corner1(1)]; % BL
        end

    catch err
        disp(strcat('ERROR: ', err.identifier));
        strip_corners = [];
        right = false;
    end

end

