function [depth, dist] = generate_depth(imagel, imager, window, range)
%%GENERATE_DEPTH generates the depth image from two stereo images
%   imagel, imager: Left image and right image
%   window        : Size of the moving window
    imager = im2double(imager); imagel = im2double(imagel);
    
    [H W] = size(imagel);
    half_window = fix(window/2);
    fixed_d = range;

    depth = zeros(H, W, 'uint8');
    dist = cell(H, W);
    
    for i=half_window+1:H-half_window
        for j=half_window+1:W-half_window
            A = imager(i - half_window: i + half_window, ...
                       j - half_window: j + half_window);
            A = A ./ sqrt(sum(sum(A.*A)));
            
            dists = zeros(size(fixed_d));
            for D=fixed_d
                if j+D+half_window > W
                    break;
                end
                B = imagel(i - half_window    : i + half_window, ...
                           j - half_window + D: j + half_window + D);
                B = B ./ sqrt(sum(sum(B.*B)));
                dists(D+1) = sum(sum(A.*B));
            end
            [~, ID] = max(dists);
            
            dist{i, j} = dists;
            depth(i, j) = ID - 1;
        end
    end
    
%     depth = depth * 16;
end