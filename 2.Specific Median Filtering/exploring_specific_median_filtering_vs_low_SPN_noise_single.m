psnr_D = zeros(1,20);
psnr_B = zeros(1,20);
for lvl = 1:20
    org = rgb2gray(imread('Lenna_512.jpg'));
    noised = imnoise(org,'Salt & Pepper',0.05*(lvl-1)); %Set the noise level
    img = noised;                       %img is noised image
    figure,imshow(img),title('Noised Image');
    N = 255;
    %img = randi(N,N,N)
    size(img)
    for i = 0:N
        A(:,:,i+1) = (img >= i); %higher SSIM with equality
    end
    Max_Iter = 30
    len = size(img,1);
    breadth = size(img,2);
    cells = A;
    x = 2:len-1;
    y = 2:breadth-1;
    z = 1:N+1;
    summed(x,y,z) = cells(x,y-1,z) + cells(x,y+1,z) + cells(x-1,y,z) + cells(x+1,y,z) + cells(x-1,y-1,z) + cells(x-1,y+1,z) + cells(x+1,y-1,z) + cells(x+1,y+1,z);
    %Black is Zero
    sumpad = padarray(summed(2:end,2:end,:),[1 1]);
    identified = (sumpad == 8 & ~cells);
    cells = cells + identified;
    identified = (sumpad == 0 & cells);
    cells = logical(mod(double(cells)+double(identified),2)); %cells is the applied CA rule collection of binaries in logical
    %Recombination
    C = zeros(size(cells,1),size(cells,2)); %summing up
    for i = 1:N+1
        C = C + cells(:,:,i);
    end
    uncorrupted = ((double(noised) ~= 0) & (double(noised) ~= 255)); %One for uncorrupted
    SS = median(cat(3,img(x,y-1),img(x,y+1),img(x-1,y),img(x+1,y),img(x-1,y-1),img(x-1,y+1),img(x+1,y-1),img(x+1,y+1)),3);
    D = uint8(double(org).*(uncorrupted) + (~uncorrupted).* double(padarray(SS,[1 1])));
    psnr_D(lvl) = psnr(D,org);
    psnr_B(lvl) = psnr(uint8(C),org);
end
