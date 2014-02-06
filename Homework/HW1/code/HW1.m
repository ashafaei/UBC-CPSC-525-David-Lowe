use = 1;

files = {'imL.jpg', 'imR.jpg', 'groundtruth.jpg', 'all.png', 'nonocc.png'};
sets          = {'cones/', 'teddy/', 'tsukuba/', 'venus/'};
ranges        = {0:59    ,  0:59   , 0:15      , 0:19    };
scales        = {4       ,  4      , 16        , 8       };

% for use=1:4,

%% Loading the data
iml = imreadgray([sets{use} files{1}]);
imr = imreadgray([sets{use} files{2}]);
%% Doing the work
fprintf('Generating disparity values\n');
tic;
[gendep_l, dists_l, invalid_map] = generate_depth_NCC(iml, imr, 15, ranges{use});
% fprintf('Doing the other way\n');
% gendep_r = generate_depth_NCC(imr, iml, 15, -ranges{use});
% fprintf('Verifying the values\n');
% %%
% valid_s  = false(size(gendep_l));
% for i=1:size(valid_s, 1)
%     for j=1:size(valid_s, 2)
%         valid_s(i, j) = abs((int16(gendep_r(i, j+gendep_l(i, j))) - int16(gendep_l(i, j)))) < 2;
%     end 
% end
% imshow(valid_s);
%%
imshow(invalid_map);

new_depth = fix_closetvalid(gendep_l, invalid_map);
%%
new_depth2 = fix_linearinterpolation(gendep_l, invalid_map);

%%
gendep = gendep_l .* scales{use};
new_depths = new_depth .* scales{use};
new_depths2 = new_depth2 .* scales{use};
% gendep = new_depths;
imshow(gendep);
toc
%%
osets          = {'conesO', 'teddyO.png', 'tsukubaO.png', 'venusO.png'};
imshow(new_depths);
figure;
imshow(new_depths2)
imwrite(new_depths, ['./output/' osets{use} 'cv.png']);
imwrite(new_depths2, ['./output/' osets{use} 'li.png']);
%% Evaluate output
truel = imreadgray([sets{use} files{3}]);
pat_all     = imreadgray([sets{use} files{4}])~=0;
pat_nonocc  = imreadgray([sets{use} files{5}])~=0;
pat_hw      = ones(size(truel));

precision = calculate_precision(truel, gendep, pat_hw, scales{use});
fprintf('Fraction of correct pixels: %0.3f\n', precision);

precision_all = calculate_precision(truel, gendep, pat_all, scales{use});
precision_nonocc = calculate_precision(truel, gendep, pat_nonocc, scales{use});
fprintf('Real precision: %0.3f\n', precision_all);
fprintf('Non-Occluded precision: %0.3f\n', precision_nonocc);
%% More analysis
% diff = abs(int16(truel)./scales{use} - int16(gendep)./scales{use});
% %count number of true assignments within one disparity;
% correct = diff < 2;
% correct_pat = correct & (pat_nonocc == 1);
% incorrect_pat = ~correct & (pat_nonocc == 1);
% 
% invalid_map_fixed = invalid_map & (pat_nonocc == 1);
% 
% marked_count = sum(sum(invalid_map_fixed));
% marked_precision = sum(sum(invalid_map_fixed & incorrect_pat))/sum(sum(incorrect_pat));
% display(marked_precision);
% 
% imshow(incorrect_pat);
% 
% [H, W] = size(correct);
% 
% error_hist = zeros (H*W, 1);
% error_ind  = 1;
% 
% correct_hist = zeros(H*W, 1);
% correct_ind = 1;
% 
% for i=1:H,
%     for j=1:W,
%         if isempty(dists_l{i, j}),
%             continue;
%         end
%         if incorrect_pat(i, j),
%            [~, IDX] = sort(dists_l{i, j});
%            f_best = 1-dists_l{i, j}(IDX(end));
%            s_best = 1-dists_l{i, j}(IDX(end-1));
%            error_hist(error_ind) = f_best/s_best;
%            error_ind = error_ind+1;
%         end
%         
%         if correct_pat(i, j),
%            [~, IDX] = sort(dists_l{i, j});
%            f_best = 1-dists_l{i, j}(IDX(end));
%            s_best = 1-dists_l{i, j}(IDX(end-1));
%            correct_hist(correct_ind) = f_best/s_best;
%            correct_ind = correct_ind+1;
%         end
%     end
% end
% 
% correct_hist = correct_hist(1:correct_ind-1);
% error_hist   = error_hist(1:error_ind-1);

% correct_hist = correct_hist / numel(correct_hist);
% error_hist   = error_hist   / numel(error_hist);
%%
% [Y, X] = hist(correct_hist, 0:0.1:1);
% Y = Y / sum(Y);
% 
% h = figure();
% set(h, 'Position', [50 50 800 600]);
% axes1 = axes('Parent',h,'YGrid','on','FontSize',11);
% handle = plot(X, Y, 'g');
% set(handle          , ...
%   'LineWidth'       , 3           , ...
%   'Marker'          , 'o'         , ...
%   'MarkerSize'      , 8           , ...
%   'MarkerEdgeColor' , [.2 .2 .2]  , ...
%   'MarkerFaceColor' , [.9 .9 .9]  , ...
%   'Color'           , [18/255 220/255 57/255], ...
%   'DisplayName'     , 'Correct');
% hold on;
% [Y, X] = hist(error_hist, 0:0.1:1);
% Y = Y / sum(Y);
% handle = plot(X, Y, 'r');
% set(handle          , ...
%   'LineWidth'       , 3           , ...
%   'Marker'          , 's'         , ...
%   'MarkerSize'      , 8           , ...
%   'MarkerEdgeColor' , [.2 .2 .2]  , ...
%   'MarkerFaceColor' , [.9 .9 .9]  , ...
%   'Color'           , [220/255 57/255 18/255], ...
%   'DisplayName'     , 'Incorrect');
% 
% legend1 = legend(axes1,'show');
% set(legend1,'Orientation','horizontal');
% 
% hTitle  = title ('');
% hXLabel = xlabel('Ratio of first best to second best'      );
% hYLabel = ylabel('Population'        );
% set( gca                             , 'FontName'   , 'Helvetica' );
% set([hTitle, hXLabel, hYLabel]       , 'FontName'   , 'AvantGarde', 'FontWeight' , 'bold');
% set(gca                              , 'FontSize'   , 12           );
% set([hXLabel, hYLabel]               , 'FontSize'   , 18          );
% set( hTitle                          , 'FontSize'   , 12          , ...
%                                        'FontWeight' , 'bold'      );
% set( legend1, 'FontSize', 14);
% xlim(axes1, [0 1]);
% ylim(axes1, [0 0.5]);
% box(axes1,'on');
% 
% save_path = sprintf('./part2/rat_w_%s.png', sets{use}(1:end-1));
% saveTightFigure(h, save_path);
% save_path = sprintf('./part2/rat_w_%s.pdf', sets{use}(1:end-1));
% saveas(h, save_path);
% 
% %% Displaying the results
% figure();
% subplot(2, 2, 1); imshow(imr); title('Right Image');
% subplot(2, 2, 2); imshow(iml); title('Left Image');
% subplot(2, 2, 3); imshow(truel);  title('Ground Truth');
% subplot(2, 2, 4); imshow(gendep); title('Calculated Disparity');
% 
% %% Error analysis
% diff = abs(int16(truel)./scales{use} - int16(gendep)./scales{use});
% 
% %count number of true assignments within one disparity;
% correct = diff < 2;
% correct = correct & (pat_nonocc == 1);
% cp = iml;
% cp(~correct) = 0;
% icp = iml;
% icp(correct | (pat_nonocc == 0)) = 0;
% imwrite(cp, ['./output/correct-' osets{use}]);
% imwrite(icp, ['./output/icorrect-' osets{use}]);
% figure;
% subplot(2, 2, 1); imshow(correct); title('Correct match');
% subplot(2, 2, 2); imshow(~correct &(pat_nonocc == 1)); title('Incorrect match');
% subplot(2, 2, 3); imshow(cp); title('Correct match');
% subplot(2, 2, 4); imshow(icp); title('Incorrect match');
% 
%% Saving the results
% osets          = {'conesO.png', 'teddyO.png', 'tsukubaO.png', 'venusO.png'};
% imwrite(gendep, ['./output/' osets{use}]);
% end
