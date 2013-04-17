fL = input('Enter filename for left image\n', 's');
fR = input('Enter filename for right image\n', 's');
ImageL = double(imread(fL));
ImageR = double(imread(fR));
[num_rows num_cols] = size(ImageL);

D = zeros(num_rows, num_cols);
Lmin_mse = 100000; Rmin_mse = 100000;
W = 3; min_D = -8; max_D = 8;

for row=1+W:num_rows-W,
    for col=1+W:num_cols-W,
        Lmin_d = 0;
        Rmin_d = 0;        
        for d=min_D:max_D,
            if col-W+d > 0 && col+W+d > 0 && col-W+d <= num_cols && col+W+d <= num_cols
                LA = ImageL(row-W:row+W, col-W:col+W);
                LB = ImageR(row-W:row+W, col-W+d:col+W+d);
                Lmse = sum(sum((LA-LB).^2));
                if Lmse < Lmin_mse
                    Lmin_mse = Lmse;
                    Lmin_d = d;
                end
                RA = ImageR(row-W:row+W, col-W:col+W);
                RB = ImageL(row-W:row+W, col-W+d:col+W+d);
                Rmse = sum(sum((RA-RB).^2));
                if Rmse < Rmin_mse
                    Rmin_mse = Rmse;
                    Rmin_d = d;
                end
            end
        end
        xr = ImageL(row, col)+Lmin_d;
        xl = xr + Rmin_d;
        if xl ~= ImageL(row, col)
            D(row, col) = min_D;
            continue;
        end
        D(row, col) = Lmin_d;
    end
end
imagesc(D, [min_D,max_D]);
colormap(gray);