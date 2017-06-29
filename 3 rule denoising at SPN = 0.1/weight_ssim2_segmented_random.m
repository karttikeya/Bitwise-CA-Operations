 function [var2beopt] = weight_ssim2_segmented_random(W,A,img,uncorrupted) % computes sum of squares from uncorrupted pixels chosen randomly.
   B = zeros(size(A,1),size(A,2));
    %ssz = 0.3;
    for i = 1:255
        B(:,:) = B(:,:) + A(:,:,i)*W(i);
    end
    tolearnfrom = B.*uncorrupted + double(img).*(~uncorrupted);
    var2beopt = sum(sum((img-tolearnfrom).^2));
    if randi(50000) == 10
        figure,imshow(uint8(B)),title(strcat('With the RMS error as ',num2str(var2beopt)));
    end
    %intf('SSIM value is %d',var2beopt)
end