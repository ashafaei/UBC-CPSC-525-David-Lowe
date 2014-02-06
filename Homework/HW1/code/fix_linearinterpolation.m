function [ new_depth ] = fix_linearinterpolation( generated_depth, invalid_map )

new_depth = generated_depth;
valid_depth = int16(generated_depth);
valid_depth(invalid_map) = -1;

[H W] = size(new_depth);

start = 0;
stop  = 0;

for i=1:H,
    for j=1:W,
        if ~invalid_map(i, j),
            if stop > start,
               dif = valid_depth(i, j)-valid_depth(i, start);
               fprintf('\tFix region %d, %d = %d, dif %.2f\n', start, j, j-start, dif); 
               step = dif / (j-start);
               rep = 1:(j-start);
               rep = rep * double(step) + double(valid_depth(i, start));
               new_depth(i, start+1:j) = rep;
            end
            start = j;
            stop = start;
        else
            stop = j;
        end
    end
    start = 0;
    stop = 0;
    fprintf('%d/%d\n', i, H);
end

end