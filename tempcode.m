clear
clc
%% Read Byte File to Raw Data
raw_time_file_name = "Data/time_x_y_z.txt";
fileID = fopen(raw_time_file_name, 'r')
file_dir = dir(raw_time_file_name)
size = file_dir.bytes % size of file in bytes
raw_data = fread(fileID, [4, size], 'int');

raw_data = raw_data((1:4),(133:size/4/4)); % trimming off zeros

%% Convert Raw Data to G's
conversion_factor = .0002441407513657033; % from arduino code (Yigit Testified)
data(1,:) = raw_data(1,:);
data(2:4,:) = raw_data(2:4,:).* conversion_factor;
data_t = transpose(data);

time = transpose(data(1,:) ./ 1000000);
accel_x = transpose(data(2,:));
accel_y = transpose(data(3,:));
accel_z = transpose(data(4,:));
dt = mean(diff(time));
%sampling frequency
Fs = 1/dt;      % unit: Hz

winsize = 2^13; %window length
[X1, f1] = pwelch(accel_z,hann(winsize),0.75*winsize,[],Fs);

figure
subplot(2,1,1)
plot(time,accel_z)
subplot(2,1,2)
plot(f1,10*log10(X1))
xlim([0 30]) %x-axis limit
