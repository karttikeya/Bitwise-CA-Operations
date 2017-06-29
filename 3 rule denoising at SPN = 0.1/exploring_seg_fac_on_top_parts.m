clear
tic
org = (imread('Lenna_128.jpg'));
psnr_B = zeros(1,5); %B is regressed learning from all
psnr_C= zeros(1,5);   %C is summing up after 2 rules
psnr_D= zeros(1,5);    %D is summing up after 1 rule
psnr_E= zeros(1,5);   % E is after median filtering on uncorrupted.
psnr_F = zeros(1,5);   % F is learning from 10% at random.
for level = 3:7
    noised = imnoise(org,'Salt & Pepper',0.02*level); %Set the noise level
    img = noised;                                %img is noised image
    N = 255;
    for i = 0:N
        A(:,:,i+1) = (img >= i); %higher SSIM with equality
    end
    Max_Iter = 25;


    %Applying two learnt rule.Using SPN ~ 10%
    len = size(img,1);
    breadth = size(img,2);
    cells = A;
    x = 2:len-1;
    y = 2:breadth-1;
    z = 1:N+1;
    summed(x,y,z) = cells(x,y-1,z) + cells(x,y+1,z) + cells(x-1,y,z) + cells(x+1,y,z) + cells(x-1,y-1,z) + cells(x-1,y+1,z) + cells(x+1,y-1,z) + cells(x+1,y+1,z);
    %Black is Zero
    sumpad = padarray(summed(2:end,2:end,:),[1 1]);

    %applying the first rule
    identified = (sumpad == 8 & ~cells);
    cells = cells + identified;
    identified = (sumpad == 0 & cells);
    cells = logical(mod(double(cells)+double(identified),2)); %cells is the applied CA rule collection of binaries in logical

    %Result after applying only the first rule in D.
    D = zeros(size(cells,1),size(cells,2)); 
    for i = 1:N+1
        D = D + cells(:,:,i);
    end

    %applying the second rule
    identified = (sumpad == 7 & ~cells);
    cells = cells + identified;
    identified = (sumpad == 1 & cells);
    cells = logical(mod(double(cells)+double(identified),2));

    %Recombination
    B = zeros(size(cells,1),size(cells,2)); 
    F = zeros(size(cells,1),size(cells,2));

    %1. Summing up - Result in C
    C = zeros(size(cells,1),size(cells,2)); 
    for i = 1:N+1
        C = C + cells(:,:,i);
    end

    %2. Using Linear Regression - Result in B

    uncorrupted = ((double(noised) ~= 0) & (double(noised) ~= 255)); %One for uncorrupted
    W1 =  randi(100,1,256)/100; %randomized initialization
    %W1 = ones(1,255)*0.5;
    options = optimoptions(@fminunc,'Display','iter','MaxIter',Max_Iter)%'StepTolerance',1e-1);
    [W,final_value] = fminunc(@(W) weight_ssim2_segmented(W,cells,double(img),uncorrupted,[1 1]),W1,options)
    for i = 1:255
        B(:,:) = B(:,:) + cells(:,:,i)*W(i);
    end

    %3.Using mediann filtering on uncorrupted - Result in E
    SS = median(cat(3,img(x,y-1),img(x,y+1),img(x-1,y),img(x+1,y),img(x-1,y-1),img(x-1,y+1),img(x+1,y-1),img(x+1,y+1)),3);
    E = uint8(double(org).*(uncorrupted) + (~uncorrupted).* double(padarray(SS,[1 1])));


    %4.Random pixels used from learning. - Results in F.
    seg_fac =3;
    chooser = (randi(seg_fac*seg_fac,size(img,1),size(img,2)) == 1);
    [ro co ~] = find(chooser);
    img_chosen = diag(img(ro,co));
    uncorrupted_chosen = diag(uncorrupted(ro,co));
    cells_chosen = zeros(size(diag(cells(ro,co,1)),1),size(diag(cells(ro,co,1)),2),N+1);
    for swq = 1:N+1
        cells_chosen(:,:,swq) = diag(cells(ro,co,swq));
    end
    W1 =  randi(100,1,256)/100;
    [W,final_value] = fminunc(@(W) weight_ssim2_segmented_random(W,cells_chosen,double(img_chosen),uncorrupted_chosen),W1,options);
    for i = 1:255
        F(:,:) = F(:,:) + cells(:,:,i)*W(i);
    end
    
    psnr_B(level-2) = psnr(uint8(B),org) %B is regressed learning from all
    psnr_C(level-2)= psnr(uint8(C),org)   %C is summing up after 2 rules
    psnr_D(level-2)= psnr(uint8(D),org)    %D is summing up after 1 rule
    psnr_E(level-2)= psnr(uint8(E),org)   % E is after median filtering on uncorrupted.
    psnr_F(level-2) = psnr(uint8(F),org)   % F is learning from 10% at random.
    toc
end