clear
% (AB) A - is the number of whites in corners, B - number of whites in middle
function output = CA(input,R) 
    output = input;
    A =   zeros(size(output,1),size(output,2));
    for (itr = 1:30 & A ~= output)
         A = output;
         x = 2:len-1;
         y = 2:breadth-1;
         first(x,y) =  A(x-1,y-1) + A(x-1,y+1) + A(x+1,y-1) + A(x+1,y+1);
         second(x,y) = A(x,y-1) + A(x,y+1) + A(x-1,y) + A(x+1,y);       
         toinvert = (input == 1);
         first(x,y) = first(x,y).*(~toinvert) + (4-first(x,y)).*(toinvert);
         second(x,y) = second(x,y).*(~toinvert) + (4-second(x,y)).*(toinvert);
         tot(x,y) = first(x,y)*10+second(x,y);          %Black is Zero
         tot(x,y) = tot(x,y) + (tot(x,y) == 0)*99;
         output(x,y) = (R(tot(x,y)) == 1).*(~A) + (R(tot(x,y) == 0)).*A;
    end
end