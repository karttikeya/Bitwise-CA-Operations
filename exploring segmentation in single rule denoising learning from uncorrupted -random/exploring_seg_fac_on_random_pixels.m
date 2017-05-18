clear
tic
psnr_B = zeros(10);
psnr_C = zeros(10);
psnr_D = zeros(10);
for factor = 2:10
    org = imread('baboon_256.jpg');
    noised = imnoise(org,'Salt & Pepper',0.01); %Set the noise level
    img = noised;                                %img is noised image
    N = 255;
    %img = randi(N,N,N)
    for i = 0:N
        A(:,:,i+1) = (img >= i); %higher SSIM with equality
    end
    Max_Iter = 30;
    %Rule application - Basic learnt rule in Rosin : Replace black by white if
    %all white surround it and inverse for white surrounded by blacks.
    %This rul alone means that we are just relacing the black pixels by minimum
    %of all the surrounding intensities and white by the maximum , if we
    %recombine by summation only.
    
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
    
    B = zeros(size(cells,1),size(cells,2)); %using regression
    uncorrupted = ((double(noised) ~= 0) & (double(noised) ~= 255)); %One for uncorrupted
    sum(sum(~uncorrupted))
    
    %W1 =  randi(100,1,256)/100; %randomized initialization
    W1 = ones(1,255)*0.5;
    
    %Choosing random pixels for learning
    seg_fac = factor ; %randomly choosing pixels.
    chooser = (randi(seg_fac*seg_fac,size(img,1),size(img,2)) == 1);
    [ro co ~] = find(chooser);
    img_chosen = diag(img(ro,co));
    uncorrupted_chosen = diag(uncorrupted(ro,co));
    cells_chosen = zeros(size(diag(cells(ro,co,1)),1),size(diag(cells(ro,co,1)),2),N+1);
    for swq = 1:N+1
        cells_chosen(:,:,swq) = diag(cells(ro,co,swq));
    end
    
    %regressing obj function , NOTE FORM IN FMINUNC
    options = optimoptions(@fminunc,'Display','iter','MaxIter',Max_Iter)%'StepTolerance',1e-1);
    [W,final_value] = fminunc(@(W) weight_ssim2_segmented_random(W,cells_chosen,double(img_chosen),uncorrupted_chosen),W1,options);
    B = zeros(size(img,1),size(img,2));
    for i = 1:255
        B(:,:) = B(:,:) + cells(:,:,i)*W(i);
    end
    W1 = ones(1,255)*0.5;
    [W,final_value] = fminunc(@(W) weight_ssim2_segmented_random(W,cells,double(img),uncorrupted),W1,options);
    D = zeros(size(img,1),size(img,2));
    for i = 1:255
        D(:,:) = D(:,:) + cells(:,:,i)*W(i);
    end
    psnr_B(factor) = psnr(uint8(B),org) %B is randomised
    psnr_C(factor) = psnr(uint8(C),org) %C is summing up
    psnr_D(factor) = psnr(uint8(D),org) %D is from seg fac = 1
    toc
end
