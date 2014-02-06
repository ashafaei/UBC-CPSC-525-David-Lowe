function [ new_depth ] = fix_closetvalid( generated_depth, invalid_map )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

new_depth = generated_depth;
valid_depth = int16(generated_depth);
valid_depth(invalid_map) = -1;

[H W] = size(new_depth);

for i=1:H,
    for j=1:W,
        if invalid_map(i, j),
           new_depth(i, j) = nearest(valid_depth, i, j); 
        end
    end
    fprintf('%d/%d\n', i, H);
end

end

%% This is supposed to be a BFS search!
function nearest_val = nearest(valid_depth, i, j)
    if i==8 && j==16,
       display(i); 
    end
    [H W] = size(valid_depth);
    marked = false(H, W);
    queue = {[i j]};
    targets = {[+1 0], [-1 0], [0 +1], [0 -1], [+1 +1], [-1 -1], [-1 +1], [+1 -1]};
    targets_size = numel(targets);
%     queue_size = 1;
    while numel(queue)>0,
       P = queue{1};
       queue = queue(2:end);
       marked(P(1), P(2)) = true;
%        queue_size = queue_size - 1;
       if valid_depth(P(1), P(2)) ~= -1,
           nearest_val = valid_depth(P(1), P(2));
           return;
       end
       
       for k=1:targets_size,
          n_p = P + targets{k};
          if n_p(1) > 0 && n_p(1)<=H && n_p(2) > 0 && n_p(2) <= W && ~ marked(n_p(1), n_p(2)),
              marked(n_p(1), n_p(2)) = true;
%               queue_size = queue_size +1;
              queue{numel(queue)+1} = n_p;
          end
       end
    end
    nearest_val = 1;
end