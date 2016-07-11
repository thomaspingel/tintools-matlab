function [ZIe ZIn] = verifytin(ZI,R,x,y,z)

    % Create the grid
    [xi yi] = ir2xiyi(ZI,R);
    [XI YI] = meshgrid(xi,yi);
%     [yp xp] = map2pix(R,XI(:),YI(:));

    % Interpolate
    TRI = TriScatteredInterp(x,y,z,'linear');
    ZIn = TRI(XI(:),YI(:));
    ZIn = reshape(ZIn,size(ZI));
    ZIe = ZI -  ZIn;
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