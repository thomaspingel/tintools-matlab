function [tri x y z] = dem2tin(ZI,R,ZImask)

    % If no referencing matrix is provided, make a generic one.
    if isempty(R)
        R = [0 1; 1 0; 0 0];
    end

    % Create the grid
    [xi yi] = ir2xiyi(ZI,R);
    [XI YI] = meshgrid(xi,yi);

    % And extract the points that fit the provided mask.
    x = XI(ZImask);
    y = YI(ZImask);
    z = ZI(ZImask);
    [yp xp] = map2pix(R,x,y);

    % Then create the triangle representation from just the x, y points
    tri = delaunay(x,y);

end

% Generic little function to get the vectors that correspond to the
% axes of the raster
function [xi yi] = ir2xiyi(I,R)
    r = size(I,1);
    c = size(I,2);
    [xb yb] = pix2map(R,[1 r],[1 c]);
    xi = xb(1):R(2):xb(2);
    yi = yb(1):R(4):yb(2);
end