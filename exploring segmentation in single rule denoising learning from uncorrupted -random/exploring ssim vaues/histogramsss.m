img = imread('barbara.png');
figure;
imhist(img);
figure;
imshow(img);
title('Original Histogram');
ssim(img,img)
x = linspace(0,1,100);
q = 0;
for val = 0:0.01:1
    q = q +1;
    y(q) = ssim(img,imnoise(img,'salt & pepper',val));
end
y
plot(x,y(1:100))
