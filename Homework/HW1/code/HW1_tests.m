use = 1;

files = {'imL.jpg', 'imR.jpg', 'groundtruth.jpg', 'all.png', 'nonocc.png'};
sets          = {'cones/', 'teddy/', 'tsukuba/', 'venus/'};
ranges        = {0:59    ,  0:59   , 0:15      , 0:19    };
scales        = {4       ,  4      , 16        , 8       };

%% Loading the data
iml = imreadgray([sets{use} files{1}]);
imr = imreadgray([sets{use} files{2}]);
%% Doing the work
fprintf('Generating disparity values\n');
tic;
gendep = generate_depth_NCC(iml, imr, 15, ranges{use});
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
%% Displaying the results
figure();
subplot(2, 2, 1); imshow(imr); title('Right Image');
subplot(2, 2, 2); imshow(iml); title('Left Image');
subplot(2, 2, 3); imshow(truel);  title('Ground Truth');
subplot(2, 2, 4); imshow(gendep); title('Calculated Disparity');

%% See dist
figure();
diff = abs(int16(truel)./scales{use} - int16(gendep)./scales{use});
%count number of true assignments within one disparity;
correct = diff < 1;
correct = correct & (pat_nonocc == 1);
selection  = gendep;
selection(~correct) = 0;
imshow(selection);
%%

dec = dists(~correct & (pat_nonocc == 1));
