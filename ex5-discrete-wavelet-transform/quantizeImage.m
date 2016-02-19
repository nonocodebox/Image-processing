function [ imQuant, error ] = quantizeImage( imOrig, nQuant, nIter, excludedRows, excludedCols )
% quantizeImage Performs quantization of an image to nQuants.
    narginchk(5, 5);
    nargoutchk(0, 2);
    
    try
        % Initialize in case of an error
        imQuant = imOrig;
        error = [];

        % Validate the number of iterations and number of quants
        if nIter <= 0 || nQuant <= 0
            disp('ERROR: invalid args');
            return;
        end
        
        working_mat = imOrig;

        % Get the image size and dimension
        im_size = size(imOrig);
        org_size = size(im_size);

        % Calculate the histogram
        histOrig = imhist(working_mat)' - imhist(working_mat(excludedRows, excludedCols))';
        
        % If we have more quants than colors in the original image, return 
        % the original image
        if nQuant < sum(histOrig > 0)
            % Initialize q and the error vector
            q = [];
            error = zeros(1, nIter);

            % Calculate the cumulative histogram
            cum_sum = cumsum(histOrig);

            % Calcuate the total number of pixels
            number_of_pixels = sum(histOrig);

            % Calculate the normalized cumulative histogram
            normalized_cumulative = (double(cum_sum) ./ number_of_pixels) .* 255;
            normalized_cumulative = round(normalized_cumulative);
            
            % Calculate how many colors each quant should contain
            colors_per_quant = 256 / nQuant;
            
            % Initialize the z vector
            z = zeros(1, nQuant + 1);
            z(end) = 255;
            
            % First border index is 1
            prev = 1;
            
            % Calculate the initial z vector
            for i = 2:nQuant
                % Find each color linearly in the normalized cumulative
                % histogram map and find its index to map the z value back
                % to the original image
                index = find(normalized_cumulative >= colors_per_quant * (i - 1));
                z(i) = index(1) - 1; % Move one index back since we want 
                                     % to start a new bin at this index
                
                % Check if the created bin is empty, if so, go back up one
                % index. We are guaranteed to have at least one pixel here
                % since we found a difference at this index.
                if cum_sum(z(i)) <= cum_sum(prev)
                    z(i) = z(i) + 1;
                end
                
                % Save the previous border index
                prev = z(i);
            end
            
            for iter = 1:nIter
                all_z = 0:255;

                % Create a vector of edges at z(i)
                edges = zeros(1, 256);
                % Add 1 because z starts at 0.
                edges(1 + z(1:end-1)) = 1;

                % Create a vector of indexes with a different index at each bin
                indexes = cumsum(edges);

                % Calculate the numerator and denominator for calculating q(i)
                numerator = accumarray(indexes', histOrig .* all_z);
                denominator = accumarray(indexes', histOrig);

                % Calculate q
                q = round(numerator ./ denominator);

                % Calculate the new z by summing adjecent z values
                z = round(conv(q, [1 1]) / 2);

                % Set borders of the new z vector
                z(1) = 0;
                z(end) = 255;

                % Create a vector of indexes using the new z
                edges = zeros(1, 256);
                edges(1 + z(1:end-1)) = 1;
                indexes = cumsum(edges);

                % Span the q vector using the indexes
                spanned_q = q(indexes);
                spanned_q = spanned_q(:)'; % Make sure spanned_q is a row vector

                % Calculate the error terms
                power_val = (spanned_q - all_z) .^ 2;
                errors = accumarray(indexes', power_val .* histOrig);

                % Sum all the terms to calculate the total error for this iteration
                error(iter) = sum(errors) / number_of_pixels;

                % Quit if the process converges
                if iter > 1 && error(iter) >= error(iter - 1)
                    % Trim the error vector
                    error(iter : end) = [];
                    break;
                end
            end
            
            % Use the spanned q vector a LUT
            lut = spanned_q;

            % Map the original colors
            excluded = working_mat(excludedRows, excludedCols);
            working_mat(excludedRows, excludedCols) = 0;
            
            final_result = double(lut(1 + round(working_mat * 255))) / 255;
            final_result(excludedRows, excludedCols) = excluded;
            
              imQuant = final_result;
        end
        
    catch err
        disp(strcat('ERROR: ', err.identifier));
        imQuant = [];
        error = [];
    end
end
