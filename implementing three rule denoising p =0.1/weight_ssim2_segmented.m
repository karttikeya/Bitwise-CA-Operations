 function [var2beopt] = weight_ssim2_segmented(W,A,img,uncorrupted,seg_fac) % computes sum of squares from uncorrupted pixels.
%     value = x^2 +36 -12*x;
   %var2beopt = abs(sum(sum(abs(W))));
   len = floor(size(img,1)/seg_fac(1));
   bre = floor(size(img,2)/seg_fac(2));
   B = zeros(len,bre);
    
    %ssz = 0.3;
    for i = 1:255
        B(:,:) = B(:,:) + A(1:len,1:bre,i)*W(i);
    end
    tolearnfrom = B.*uncorrupted(1:len,1:bre) + img(1:len,1:bre).*(~uncorrupted(1:len,1:bre));
    var2beopt = sum(sum((img(1:len,1:bre)-tolearnfrom).^2));
    if randi(50000) == 10
        figure,imshow(uint8(B)),title(strcat('With the RMS error as ',num2str(var2beopt)));
    end
    %intf('SSIM value is %d',var2beopt)
end