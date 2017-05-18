clear
filename = 'baboon.jpg'
try
    x = 'In catch now'
    img = rgb2gray(imread(filename));
catch
    img = (imread(filename));
end
[count , ~] = imhist(img);
for i = 0:255
    A(:,:,i+1) = (img >= i);
end
B = zeros(size(img));
for i =0:255
    B(:,:) = B(:,:) + A(:,:,i+1);
end
B = B + (B < 1)*3;
B = im2uint8(B,'indexed');
imshow(B)
title('REMADE');
figure;
imshow(img);
title('Actual');
B = zeros(size(img));
for i =0:255
    B(:,:) = B(:,:) + A(:,:,i+1)*(i)*(count(i+1)/(size(img,1)*size(img,2)));
end
figure;
imhist(img)
title('Actual');
B = ceil(B);
B = uint8(B);
figure;
imhist(B);
title('Remade bu algo');
figure
imshow(B)
title('REMADE BY ALGO');
ssim(img,B)
imwrite(B, sprintf(' %d.jpg',128))
