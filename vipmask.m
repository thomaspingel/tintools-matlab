% function [tri x y z mask] = vipmask(ZI,thresh,keepcorners)
%
% Creates a mask of the Very Important Points on the raster, according to 
% algorithm of Chen and Guevara (1987). 
%
% In each of four directions (E/W,N/W,NE/SW,NW/SE) the VIP algorithm finds 
% the shortest distance bewteen each pixel and a line drawn between its two 
% neighbors.  The "measure of significance" for each pixel is the sum of 
% these four distances.
%
% Threshold can be specified as (a) a proportion of points to keep 
% (between 0 and 1) or (b) as an absolute number of points to keep or (c) 
% a value representing the minimum acceptable measure of significance 
% value to retain.

function [ZImask] = vipmask(ZI,thresh,keepcorners)

    if nargin < 3
        keepcorners = true;
    end

    [rows cols] = size(ZI);
    n           = rows * cols;
    
    
    k = 4;                                 % Number of directions to search
    distanceMatrix = zeros(rows,cols,k);   % Holds distance (height) values
                                           % for each direction

                                           
    for i = 1:k     % Calculate shortest distance for each direction
        
        % Shift the image, and reorder into a [3 n] list
        s = shifter(ZI,i);                                
        r = reshape(permute(s,[3 1 2]),[3 numel(ZI)])';  
    
        % Find and record the height for each pixel
        if (i < 3)      h = findheight(r,1);
        else            h = findheight(r,sqrt(2));
        end
        
        % Reshape back into a [rows cols] sized matrix and store
        distanceMatrix(:,:,i) = reshape(h,[rows cols]);
        
    end
    clear i k s r d h

    
    
    % The measure of significance is the sum of the distanceMatrix for each
    % pixel.
    ZId = mean(distanceMatrix,3);
    clear distanceMatrix

    
    
    % The mask is defined by the threshold.  If the threshold is between 0
    % and 1, assume a proportion to keep.  If one or greater, assume it is 
    % an absolute number of pixels to keep.
    
    % Always select the corner pixels
    ZImask = logical(zeros(rows,cols));
    cornerPixels = sub2ind([rows cols],[1 1 rows rows],[1 cols cols 1]);
    if keepcorners
        ZImask(cornerPixels) = 1;
    end
    
    if ~ischar(thresh)
        if (thresh > 0) && (thresh < 1)
            ZImask = (ZImask | ZId >= prctile(ZId(:), 100 - 100*thresh));
        else
            if (thresh > numel(ZId)) 
                ZImask = logical(ones(rows,cols));
            else
                pointer = thresh-4;
                [B IX] = sort(ZId(:),1,'descend');
                ZImask(IX(1:pointer)) = 1;
                if keepcorners 
                        ZImask(cornerPixels) = 1;
                end
                while (sum(ZImask(:)) < thresh)
                    ZImask(IX(pointer)) = 1;
                    pointer = pointer + 1;
                end
            end
        end
    else
        ZImask = ZImask | ZId > str2num(thresh);
    end
    
end

    
    
% Shifts the raster according to the specified direction.
function [ZI3] = shifter(ZI,d)
    [r c] = size(ZI);
    ZI3 = zeros([r c 3]);
    ZI3(:,:,1) = ZI;
    ZI3(:,:,2) = ZI;
    ZI3(:,:,3) = ZI;
    switch d
        case 1  % left-right shift
            ZI3(:,1:end-1,1) = ZI(:,2:end);
            ZI3(:,2:end,3) = ZI(:,1:end-1);
        case 2  % up-down shift
            ZI3(1:end-1,:,1) = ZI(2:end,:);
            ZI3(2:end,:,3) = ZI(1:end-1,:);
        case 3  % diagonal, NE/SW shift
            ZI3(1:end-1,1:end-1,1) = ZI(2:end,2:end);
            ZI3(2:end,2:end,3) = ZI(1:end-1,1:end-1);
        case 4  % diagonal, NE/SW shift
            ZI3(1:end-1,2:end,1) = ZI(2:end,1:end-1);
            ZI3(2:end,1:end-1,3) = ZI(1:end-1,2:end);
    end
end    
    
    
    
    
    
% Calculates the height of the triangle formed by a special kind of 2D
% triangle, where the x-distance between columns of y is equal to xdist.
% The height is between the middle point to the line formed by drawing a
% line between the first and third points.
%
% I found:
% http://www.topcoder.com/tc?d1=tutorials&d2=geometry1&module=Static
% quite useful during the preparation of this function.
function [h] = findheight(y,xdist)
    n = size(y,1);
    % Find the cross product, and calculate length
    cp = abs(cross([-xdist*ones(n,1) (y(:,1)-y(:,2)) zeros(n,1)],...
                   [xdist*ones(n,1) (y(:,3)-y(:,2)) zeros(n,1)]));
    cp = sqrt(cp(:,1).^2 + cp(:,2).^2 + cp(:,3).^2);
    % Calculate the base
    b = sqrt((2*xdist*ones(n,1)).^2 + (y(:,3)-y(:,1)).^2);
    % Calculate height
    h = cp ./ b;
end