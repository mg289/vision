% Eigenface Facial Recognition using images from the Olivetti Research Laboratory face database

num_subjects=25; 
Img=[];
figure(1);
for i=1:num_subjects 
    filename=strcat('ORL/s', int2str(i), '/1.pgm');
    img=double(imread(filename));
    subplot(ceil(sqrt(num_subjects)),ceil(sqrt(num_subjects)),i);
    imshow(img);
    drawnow;
    [num_rows num_cols]=size(img);
    Img=[Img reshape(img',num_cols*num_rows,1)];
end
 
% TO DO: Normalize?
 
% mean image
mean_img=mean(Img,2);
img=reshape(uint8(mean_img),num_cols,num_rows)';
figure(2);
imshow(img);
title('Mean Image','fontsize',16)
 
A=Img';
L=A*A';
[eig_vals eig_vectors]=eig(L);
eig_val=[];
eig_vector=[];
thresh = 10^-4;
for i=1:size(eig_vals,2)
    if(eig_vectors(i,i)>thresh)
        eig_val=[eig_val eig_vals(:,i)];
        eig_vector=[eig_vector eig_vectors(i,i)];
    end
end
 
%sort ascending
[B index]=sort(eig_vector);
e_val_tmp=zeros(size(eig_val));
len=length(index);
for i=1:len
    eig_vector(i)=B(len-i+1);
    e_val_tmp(:,len-index(i)+1)=eig_val(:,i);
end
eig_val=e_val_tmp;

%Eigenvectors from covariance
u=[];
for i=1:size(eig_val,2)
    u=[u (Img*eig_val(:,i))./(sqrt(eig_vector(i)))];
end
 
for i=1:size(u,2)
    ji=u(:,i);
    u(:,i)=u(:,i)./(sqrt(sum(ji.^2)));
end
 
figure(3);
for i=1:size(u,2)
    subplot(ceil(sqrt(num_subjects)),ceil(sqrt(num_subjects)),i);
	imgshow(reshape(u(:,i),num_cols,num_rows)');
    drawnow;
end
 
% image weights - training images
omega = [];
for i=1:size(Img,2)
    curr=[]; 
    for j=1:size(u,2)
        img_weight = dot(u(:,j)',Img(:,j)');
        curr = [curr; img_weight];
    end
    omega = [omega curr];
end
 
% Testing Phase
filename = input('Enter filename for test image\n','s');
in_img = imread(filename);
figure(4)
subplot(1,2,1)
imshow(in_img);
colormap('gray');
title('Input image','fontsize',16);

[num_rows num_cols]=size(in_img);
input_img=reshape(double(in_img)',num_cols*num_rows,1); 
difference = input_img-mean_img;
 
p = [];
len=size(u,2);
for i = 1:len
    p = [p; dot(input_img,u(:,i))];
end

reshaped = reshape((u(:,1:len)*p)+mean_img,num_cols,num_rows)'; 
subplot(1,2,2)
imagesc(reshaped);
colormap('gray');
title('Reconstruction','fontsize',16);
 
weight_img = [];
for i=1:len
    weight_img = [weight_img; dot(u(:,i)',difference')];
end
 
% Euclidean distance
min_distance = 99999;
subject = 1;
for i=1:size(omega,2)
    dist = norm(weight_img-omega(:,i));
    if dist < min_distance
        min_distance = dist;
        subject = i;
    end
end
 
img = imread(strcat('ORL/s', int2str(subject), '/1.pgm'));
thresh = 13000;
figure(6);
imshow(img);

if min_distance < thresh
    title('Subject recognized','fontsize',16)
    disp('Face recognized');
    disp(strcat('Minimum Euclidean distance: ', num2str(min_distance), ' with subject: ', num2str(subject)));
else
    title('Not recognized - closest image','fontsize',12)
    disp('Face not recognized');
    disp(strcat('Minimum Euclidean distance: ', num2str(min_distance), ' with subject: ', num2str(subject)));
end