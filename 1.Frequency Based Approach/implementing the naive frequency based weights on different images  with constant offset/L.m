clear
filename = 'zelda'
img = (imread(strcat(filename,'.png')));
[count , ~] = imhist(img);
for i = 0:255
    A(:,:,i+1) = (img >= i); %higher SSIM with equality
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
offset = (sum(sum(img)))/(size(img,1)*size(img,2));
ssim(img,B);
ssim(img,B+offset);
figure,imshow(B+offset),title(strcat('With estimated offset- ',num2str(offset),'the ssim is ',ssim(img,B+offset)));
imwrite(B+offset,strcat('Estimated offset ',filename,'.jpg'),'jpeg')
offplot = zeros(1,255);
for i = 1: 255
    offplot(i) = ssim(img,B+i);
end
figure,plot(linspace(1,255,255),offplot),title('Plot of SSIM for different offsets');
imwrite(plot(linspace(1,255,255),offplot),strcat('Plot ',filename,'.jpg'),'jpeg')
[value,index] = max(offplot);
figure,imshow(B + max(max(offplot))),title(strcat('Remade with Optimised Offset ',num2str(index),'giving SSIM ',num2str(value)));
imwrite(B + max(max(offplot)),strcat('Image with optimised offset ',filename,'.jpg'),'jpeg')
figure,imhist(B + max(max(offplot))),title(strcat('Remade with Optimised Offset',num2str(index),'giving SSIM ',num2str(value)));