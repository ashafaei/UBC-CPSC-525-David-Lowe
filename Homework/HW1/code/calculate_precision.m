function correct_fraction = calculate_precision( ground_truth, calculated, pattern , scale)
%%CALCULATE_ERROR calculates the fraction of correctly computed depth 
%%against the ground truth data. Errors within one value are ignored.

diff = abs(int16(ground_truth)./scale - int16(calculated)./scale);

%count number of true assignments within one disparity;
correct = diff < 2;
correct = correct & (pattern == 1);
count = sum(sum(correct));

correct_fraction = count / sum(sum(pattern == 1));

end