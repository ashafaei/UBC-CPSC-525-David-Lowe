function [depth, dist] = generate_depth_rt(imagel, imager, window, range)
%%GENERATE_DEPTH generates the depth image from two stereo images
%   imagel, imager: Left image and right image
%   window        : Size of the moving window
    imager = im2double(imager); imagel = im2double(imagel);
    
    [H W] = size(imagel);
    half_window = fix(window/2);
    fixed_d = range;
    bits = 128;
    tests_i = randi(window, [bits 2]);
    tests_j = randi(window, [bits 2]);
    
    depth = zeros(H, W, 'uint8');
    dist = cell(H, W);
    myfilter = fspecial('gaussian', [7 7] , 4);
    imagel = imfilter(imagel, myfilter, 'replicate');
    imager = imfilter(imager, myfilter, 'replicate');

    for i=half_window+1:H-half_window
        fprintf('%d/%d\n', i, H-half_window);
        for j=half_window+1:W-half_window
            A_s = imager(i - half_window: i + half_window, ...
                       j - half_window: j + half_window);
%             A_s = imfilter(A, myfilter, 'replicate');


            for b=1:bits,
                i1 = tests_i(b, 1); i2 = tests_i(b, 2);
                j1 = tests_j(b, 1); j2 = tests_j(b, 2);

                if A_s(i1, j1) <= A_s(i2, j2)
                    tests_i(b, :) = flipdim(tests_i(b, :), 2);
                    tests_j(b, :) = flipdim(tests_j(b, :), 2);
                end
            end
            
            
            dists = zeros(size(fixed_d));
            for D=fixed_d
                if j+D+half_window > W
                    break;
                end
                B_s = imagel(i - half_window    : i + half_window, ...
                           j - half_window + D: j + half_window + D);
%                 B_s = imfilter(B, myfilter, 'replicate');
                
                        r = 0;
                for b=1:bits,
                    i1 = tests_i(b, 1); i2 = tests_i(b, 2);
                    j1 = tests_j(b, 1); j2 = tests_j(b, 2);
                    if B_s(i1, j1) > B_s(i2, j2),
                       r = r+1; 
                    end
                end

                dists(D+1) = r;
            end
            [val, ID] = max(dists);
            dist{i, j} = dists;
            if val < 115,
                
            end
            depth(i, j) = ID - 1;
        end
    end
    
%     depth = depth * 16;
end