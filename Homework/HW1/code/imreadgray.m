function image = imreadgray( path )
    image = imread(path);
    if ndims(image) > 2
        image = rgb2gray(image);
    end
end