function [ Tout ] = imgToPanoramaCoordinates(Tin)
% Tout{k} transforms image i to the coordinates system of the Panorama Image.
%
% Arguments:
% Tin - A set of transformations (cell array) such that T{i} transfroms
% image i+1 to image i.
%
% Returns:
% Tout - a set of transformations (cell array) such that T{i} transforms
% image i to the panorama corrdinate system which is the the corrdinates
% system of the first image.

    narginchk(1, 1);
    nargoutchk(0, 1);

    try
        % Get the target number of transformations (+1 for first image)
        size_tform = size(Tin, 1);
        
        % Initialize the output cell array
        Tout = cell(size_tform, 1);
        
        % First image transformation is the identity matrix
        Tout{1} = Tin{1};
        
        % Recursively multiply each transformation to get the total
        % transformation for each image
        for i=2:size_tform
           Tout{i} = Tin{i} * Tout{i - 1};
        end

    catch err
        disp(strcat('ERROR: ', err.identifier));
        Tout = [];
    end
end
