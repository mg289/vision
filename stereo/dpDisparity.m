fL = input('Enter filename for left image\n', 's');
fR = input('Enter filename for right image\n', 's');
ImageL = double(imread(fL));
ImageR = double(imread(fR));
[num_rows num_cols]= size(imageL);
c = input('Enter constant cost\n');

DisparityMatrix = zeros(num_rows, num_cols);
W = 3; max_disparity = 0; min_disparity = 0;

for row=1:num_rows
    D = zeros(num_cols, num_cols);
    % Base cases
    D(1,1) = 0;
    for i=1:num_cols,
        D(i, 1) = i*c;
        D(1, i) = i*c;
    end
	
    for i=2:num_cols,
        for j=2:num_cols,
            has_matchable_patch = false;
            if j-W > 0 && j+W <= num_cols && i-W > 0 && i+W <= num_cols && row-W > 0 && row+W <= num_rows
                has_matchable_patch = true;
                A = ImageL(row-W:row+W, i-W:i+W);
                B = ImageR(row-W:row+W, j-W:j+W);
                mse = (1/((2*W+1)^2))*sum(sum((A-B).^2));
            end
            costB = D(i-1, j) + c;
            costC = D(i, j-1) + c;
            if has_matchable_patch
                D(i,j) = min([mse, costB, costC]);
            else
                D(i,j) = min([costB, costC]);
            end
        end
    end
    x = num_cols;
    y = num_cols;
    xvals = [];
    yvals = [];
    disparity = 0;
    while x ~= 1 || y ~= 1
        xvals = [xvals x];
        yvals = [yvals y];
        if x-1 > 0 && y-1 > 0
            min_d = min([D(x-1, y-1), D(x-1, y), D(x, y-1)]);
            if min_d == D(x-1,y-1)
                x = x-1;
                y = y-1;
            elseif min_d == D(x-1,y)
                disparity = disparity + 1;
                x = x-1;
            elseif min_d == D(x,y-1)
                disparity = disparity - 1;
                y = y-1;
            end
        elseif x-1 > 0
            disparity = disparity + 1;
            x = x-1;
        elseif y-1 > 0
            disparity = disparity - 1;
            y = y-1;
        end
        DisparityMatrix(row, y) = disparity;
    end
    if disparity > max_disparity
        max_disparity = disparity;
    end
    if disparity < min_disparity
        min_disparity = disparity;
    end
end
imagesc(DisparityMatrix);
colormap(gray);