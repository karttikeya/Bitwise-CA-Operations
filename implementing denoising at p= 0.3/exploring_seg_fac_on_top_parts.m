tic
org = (imread('Lenna_50.jpg'));

noised = imnoise(org,'Salt & Pepper',0.2); %Set the noise level
img = noised;                                %img is noised image
N = 255;
for i = 0:N
    A(:,:,i+1) = (img >= i); %higher SSIM with equality
end
Max_Iter = 50000;


%Applying FIVE learnt rule.Using SPN ~ 30%
len = size(img,1);
breadth = size(img,2);
cells = A;
x = 2:len-1;
y = 2:breadth-1;
z = 1:N+1; %Here zero is black
xcoor(x,y,z) = -cells(x-1,y-1,z)+cells(x+1,y-1,z)-cells(x-1,y,z)+cells(x+1,y,z)-cells(x-1,y+1,z)+cells(x+1,y+1,z); %For logic refer convention.txt
ycoor(x,y,z) = -cells(x-1,y-1,z)-cells(x,y-1,z)-cells(x+1,y-1,z)+cells(x,y+1,z)+cells(x-1,y+1,z)+cells(x+1,y+1,z); 
zcoor(x,y,z) = 10*(cells(x-1,y-1,z)+cells(x+1,y-1,z)+cells(x-1,y+1,z)+cells(x+1,y+1,z)); 
summedw(x,y,z) = xcoor(x,y,z).^2 + ycoor(x,y,z).^2 + zcoor(x,y,z).^2;
summedw = padarray(summedw(2:end,2:end,:),[1 1]);
summed(x,y,z) =  cells(x,y-1,z) + cells(x,y+1,z) + cells(x-1,y,z) + cells(x+1,y,z) + cells(x-1,y-1,z) + cells(x-1,y+1,z) + cells(x+1,y-1,z) + cells(x+1,y+1,z);
cells = ~cells;
xcoor(x,y,z) = double(-cells(x-1,y-1,z)+0*cells(x,y-1,z)+cells(x+1,y-1,z)-cells(x-1,y,z)+0*cells(x,y+1,z)+cells(x+1,y,z)-cells(x-1,y+1,z)+cells(x+1,y+1,z));
ycoor(x,y,z) = double(-cells(x-1,y-1,z)-cells(x,y-1,z)-cells(x+1,y-1,z)+cells(x,y+1,z)+cells(x-1,y+1,z)+cells(x+1,y+1,z)); 
zcoor(x,y,z) = double(10*(cells(x-1,y-1,z)+cells(x+1,y-1,z)+cells(x-1,y+1,z)+cells(x+1,y+1,z))); 
summedb(x,y,z) = xcoor(x,y,z).^2 + ycoor(x,y,z).^2 + zcoor(x,y,z).^2;
summedb = padarray(summedb(2:end,2:end,:),[1 1]);
cells = ~cells;

%Black is Zero
sumpad = padarray(summed(2:end,2:end,:),[1 1]);

%applying the first rule
identified = (sumpad == 8 & ~cells);
cells = cells + identified;
identified = (sumpad == 0 & cells);
cells = logical(mod(double(cells)+double(identified),2)); %cells is the applied CA rule collection of binaries in logical


%applying the second rule
identified = (sumpad == 7 & ~cells);
cells = cells + identified;
identified = (sumpad == 1 & cells);
cells = logical(mod(double(cells)+double(identified),2));

cells_two = cells;

%appyling rules with two highlighted
identified = ((sumpad == 6) & (summedb == 105) & ~cells);   
cells = cells + identified;
identified = ((sumpad == 2) & (summedw == 105 & cells));
cells = logical(mod(double(cells)+double(identified),2));

identified = ((sumpad == 6) & (summedb == 404) & ~cells);
cells = cells + identified;
identified = ((sumpad == 2) & (summedw == 404) & cells);
cells = logical(mod(double(cells)+double(identified),2));

%Recombination
F = zeros(size(cells,1),size(cells,2));

%3.Using mediann filtering on uncorrupted - Result in E
uncorrupted = ((double(noised) ~= 0) & (double(noised) ~= 255)); %One for uncorrupted
SS = median(cat(3,img(x,y-1),img(x,y+1),img(x-1,y),img(x+1,y),img(x-1,y-1),img(x-1,y+1),img(x+1,y-1),img(x+1,y+1)),3);
E = uint8(double(org).*(uncorrupted) + (~uncorrupted).* double(padarray(SS,[1 1])));


%4.Random pixels used from learning. - Results in F.
seg_fac =1;
chooser = (randi(seg_fac*seg_fac,size(img,1),size(img,2)) == 1);
[ro co ~] = find(chooser);
img_chosen = diag(img(ro,co));
uncorrupted_chosen = diag(uncorrupted(ro,co));
cells_chosen = zeros(size(diag(cells(ro,co,1)),1),size(diag(cells(ro,co,1)),2),N+1);
for swq = 1:N+1
    cells_chosen(:,:,swq) = diag(cells(ro,co,swq));
end
%options = optimoptions(@fminunc,'Display','iter','MaxIter',Max_Iter,'MaxFunctionEvaluations',100000)%'StepTolerance',1e-1);
W =  randi(100,1,256)/100;
%[W,final_value] = fminunc(@(W)
%weight_ssim2_segmented_random(W,cells_chosen,double(img_chosen),uncorrupted_chosen),W,options);3
lb = ones(1,256)*-2;
ub = ones(1,256)*2;
options = saoptimset('PlotFcns',{@saplotbestx,@saplotbestf,@saplotx,@saplotf});
W = simulannealbnd(@(W) weight_ssim2_segmented_random(W,cells_chosen,double(img_chosen),uncorrupted_chosen),W,lb,ub,options);
for i = 1:255
    F(:,:) = F(:,:) + cells(:,:,i)*W(i);
end

toc
