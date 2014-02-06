function [depth, dist, invalid] = generate_depth_NCC(imagel, imager, window, range)
%%GENERATE_DEPTH_NCC generates the depth image from two stereo images using NCC
%   imagel, imager: Left image and right image
%   window        : Size of the moving window
    imager = im2double(imager); imagel = im2double(imagel);
    
    [H W] = size(imagel);
    half_window = fix(window/2);
    fixed_d = range;

    depth = zeros(H, W, 'uint8');
    invalid = false(H, W);
    dist = cell(H, W);
    
    for i=half_window+1:H-half_window
        for j=half_window+1:W-half_window
            A = imager(i - half_window: i + half_window, ...
                       j - half_window: j + half_window);
            A_mean = mean(reshape(A, window*window, 1));
            A = A - A_mean;
            
            A_len = sum(sum(A .* A));
            
            dists = zeros(size(fixed_d));
            for D=fixed_d
                if j+D+half_window > W || j+D-half_window < 1
                    break;
                end
                B = imagel(i - half_window    : i + half_window, ...
                           j - half_window + D: j + half_window + D);
                B_mean = mean(reshape(B, window*window, 1));
                B = B - B_mean;
                B_len = sum(sum(B .* B));
                       
                dists(abs(D)+1) = sum(sum(A .* B))/sqrt(A_len * B_len);
            end
            [~, ID] = max(dists);
            
            dist{i, j} = dists;
            depth(i, j) = ID - 1;
            
            [~, IDX] = sort(dists);
            f_best = 1-dists(IDX(end));
            s_best = 1-dists(IDX(end-1));
            invalid(i, j) = (f_best/s_best >= 0.8);
            
        end
    end
    
%     depth = depth * 16;
end