function M  = SUM_MAT(input)
variable=zeros(height(input),1);
for i=1:width(input)
    variable=variable+input(:,i);
end
M=variable;
end