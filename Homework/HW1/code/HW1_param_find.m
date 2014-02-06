use = 3;


for use=1:4,

files = {'imL.jpg', 'imR.jpg', 'groundtruth.jpg', 'all.png', 'nonocc.png'};
sets          = {'cones/', 'teddy/', 'tsukuba/', 'venus/'};
ranges        = {0:59    ,  0:59   , 0:15      , 0:19    };
scales        = {4       ,  4      , 16        , 8       };

%% Loading the data
iml = imreadgray([sets{use} files{1}]);
imr = imreadgray([sets{use} files{2}]);
%% Doing the work
range_s = 1:2:55;
errors = zeros(numel(range_s), 3);
images = cell(numel(range_s), 1);
for w = 1:numel(range_s)
    fprintf('Doing %dx%d %d/%d\n', range_s(w), range_s(w), w, numel(range_s));
    fprintf('Generating disparity values\n');
    tic;
    gendep = generate_depth_NCC(iml, imr, range_s(w), ranges{use});
    gendep = gendep .* scales{use};
    toc
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
    errors(w, 1) = precision;
    errors(w, 2) = precision_all;
    errors(w, 3) = precision_nonocc;
    images{w}    = gendep;
end

save_path = sprintf('./part2/env-%s.mat', sets{use}(1:end-1));
save (save_path, 'range_s', 'errors', 'images');
%% Displaying the results
h = figure();
set(h, 'Position', [100 100 800 600]);
axes1 = axes('Parent',h,'YGrid','on','FontSize',11);
xlim(axes1, [range_s(1) range_s(end)]);
ylim(axes1, [0 1]);
box(axes1,'on');

hold on;

handle = plot(range_s, errors(:, 2));
set(handle          , ...
  'LineWidth'       , 3           , ...
  'LineStyle'       , '-.'        , ...
  'Marker'          , 'o'         , ...
  'MarkerSize'      , 8           , ...
  'MarkerEdgeColor' , [.2 .2 .2]  , ...
  'MarkerFaceColor' , [.9 .9 .9]  , ...
  'Color'           , [51/255 102/255 204/255], ...
  'DisplayName'     , 'all');

% handle = plot(range_s, errors(:, 1));
% set(handle          , ...
%   'LineWidth'       , 3           , ...
%   'Marker'          , '>'         , ...
%   'MarkerSize'      , 8           , ...
%   'MarkerEdgeColor' , [.2 .2 .2]  , ...
%   'MarkerFaceColor' , [.9 .9 .9]  , ...
%   'Color'           , [220/255 57/255 18/255], ...
%   'DisplayName'     , 'all');

handle = plot(range_s, errors(:, 3));

set(handle          , ...
  'LineWidth'       , 3          , ...
  'Marker'          , 's'         , ...
  'MarkerSize'      , 8           , ...
  'MarkerEdgeColor' , [.2 .2 .2]  , ...
  'MarkerFaceColor' , [.9 .9 .9]  , ...
  'Color'           , [255/255 183/255 0/255], ...
  'DisplayName'     , 'nonocc');

legend1 = legend(axes1,'show');
set(legend1,'Orientation','horizontal');

hTitle  = title ('');
hXLabel = xlabel('Window Size'      );
hYLabel = ylabel('Precision'        );
set( gca                             , 'FontName'   , 'Helvetica' );
set([hTitle, hXLabel, hYLabel]       , 'FontName'   , 'AvantGarde', 'FontWeight' , 'bold');
set(gca                              , 'FontSize'   , 12           );
set([hXLabel, hYLabel]               , 'FontSize'   , 18          );
set( hTitle                          , 'FontSize'   , 12          , ...
                                       'FontWeight' , 'bold'      );
set( legend1, 'FontSize', 14);

hold off;
save_path = sprintf('./part2/fig_w_%s.png', sets{use}(1:end-1));
saveTightFigure(h, save_path);
save_path = sprintf('./part2/fig_w_%s.pdf', sets{use}(1:end-1));
saveas(h, save_path);

%% Show images;
h_2 = figure();
% set(h_2, 'Position', [100 100 600 800]);
for i=2:11
%     subplot(7,4,i);
    subaxis(2,5,i-1, 'Spacing', 0.02, 'Padding', 0, 'Margin', 0.04);
    imshow(images{i}); title(range_s(i));
    axis tight;
    axis off;
end
save_path = sprintf('./part2/fig_pictures_%s.png', sets{use}(1:end-1));
saveas(h_2, save_path);
end