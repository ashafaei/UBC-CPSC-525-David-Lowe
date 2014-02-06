use = 1;

% Definition of dataset
files = {'imL.jpg', 'imR.jpg', 'groundtruth.jpg', 'all.png', 'nonocc.png'};
sets          = {'cones/', 'teddy/', 'tsukuba/', 'venus/'};
ranges        = {0:59    ,  0:59   , 0:15      , 0:19    };
scales        = {4       ,  4      , 16        , 8       };

%% Loading the data
iml = imreadgray([sets{use} files{1}]);
imr = imreadgray([sets{use} files{2}]);

%% Finding disparity
fprintf('Generating disparity values\n');
tic;
[gendep_l, dists_l, invalid_map] = generate_depth_NCC(iml, imr, 15, ranges{use});
toc
%% Filling the invalid region
new_depth  = fix_closetvalid(gendep_l, invalid_map);
new_depth2 = fix_linearinterpolation(gendep_l, invalid_map);

%% Scales the disparity image
gendep            = gendep_l    .* scales{use};
new_depth_scaled  = new_depth   .* scales{use};
new_depth2_scaled = new_depth2  .* scales{use};

%% Evaluate output
truel       = imreadgray([sets{use} files{3}]);
pat_all     = imreadgray([sets{use} files{4}]) ~= 0;
pat_nonocc  = imreadgray([sets{use} files{5}]) ~= 0;

precision_all    = calculate_precision(truel, gendep, pat_all,    scales{use});
precision_nonocc = calculate_precision(truel, gendep, pat_nonocc, scales{use});
fprintf('Real precision: %0.3f\n', precision_all);
fprintf('Non-Occluded precision: %0.3f\n', precision_nonocc);

precision_nonocc_d1 = calculate_precision(new_depth_scaled , gendep, pat_nonocc, scales{use});
precision_nonocc_d2 = calculate_precision(new_depth2_scaled, gendep, pat_nonocc, scales{use});

%% Saving the results
osets          = {'conesO.png', 'teddyO.png', 'tsukubaO.png', 'venusO.png'};
imwrite(gendep, ['./output/' osets{use}]);
