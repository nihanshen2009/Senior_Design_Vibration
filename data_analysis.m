filename = "out.csv";

datas = csvread(filename);


oldData = datas(1);
differences = zeros(size(datas));

for i = (2:1:size(datas))
    differences(i) = datas(i) - datas(i-1);
    
end