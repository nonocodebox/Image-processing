function [ imgs ] = loadImages( directoryPath )
% Read all images from directoryPath
%
% Arguments:
% directoryPath - A string with the directory path
%
% Returns
% imgs - 4 dimensional vector, where imgs(:,:,:,k) is the k-th
% image in RGB format.

    narginchk(1, 1);
    nargoutchk(0, 1);

    try
        % Get the directory contents
        list_folder = dir(directoryPath);
        
        % Number of files found
        nfiles = length(list_folder);
        
        imgs = [];
        found_first = false;
        j = 1;
        
        % Continue reading after the first image
        for i = 1:nfiles
            if list_folder(i).isdir == 0 % Skip directories
                % Read and convert the next image
                img = imReadAndConvert(fullfile(directoryPath, list_folder(i).name), 2);
                
                if ~found_first
                    % Get the image size
                    img_size = size(img);

                    % Create the image list
                    imgs = zeros(img_size(1), img_size(2), img_size(3), nfiles);
                    
                    found_first = true;
                end
                
                % Place the image in the list
                imgs(:,:,:,j) = img;
                j = j + 1;
            end
        end
        
        imgs(:,:,:,j:end) = [];
    catch err
        imgs = [];
        disp(strcat('ERROR: ', err.identifier));
    end
end

