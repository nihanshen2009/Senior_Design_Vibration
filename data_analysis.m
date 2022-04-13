clear
clc
%% Read Byte File to Raw Data
raw_time_file_name = "Data/stem nut.txt";
fileID = fopen(raw_time_file_name, 'r')
file_dir = dir(raw_time_file_name)
size = file_dir.bytes % size of file in bytes
raw_data = fread(fileID, [4, size], 'int');
raw_data = raw_data((1:4),(33:size/4/4)); % trimming off zeros to acount for teensy setup time

%% Read flow rate file
flowrate_time = readtable('Data/B62 Unmodified Valve Flow Data.xlsx', 'Range', 'F:F');
flowrate_gpm =  readtable('Data/B62 Unmodified Valve Flow Data.xlsx', 'Range', 'G:G');
flowrate_time = table2array(flowrate_time);
flowrate_gpm = table2array(flowrate_gpm);

%% Convert Raw Data to G's
conversion_factor = .0002441407513657033; % from arduino code (Yigit Testified)
data(1,:) = raw_data(1,:);
data(2:4,:) = raw_data(2:4,:).* conversion_factor; % apply conversion factor to turn into G's
data(3,:) = data(3,:) - 1; % get rid of gravity in y direction

%% Hard Dividing data to different flowrate zones
% flowrate data
flowrate_time_600 = flowrate_time(5001:17001);                          % 360-480
flowrate_time_1100 = flowrate_time((840-310)*100+1:(960-310)*100+1);    % 840-960
flowrate_time_1600 = flowrate_time((1200-310)*100+1:(1320-310)*100+1);  % 1200-1320
flowrate_time_2000 = flowrate_time((1720-310)*100+1:(1840-310)*100+1);  % 1720-1840


flowrate_gpm_600 = flowrate_gpm(5001:17001);                          % 360-480
flowrate_gpm_1100 = flowrate_gpm((840-310)*100+1:(960-310)*100+1);    % 840-960
flowrate_gpm_1600 = flowrate_gpm((1200-310)*100+1:(1320-310)*100+1);  % 1200-1320
flowrate_gpm_2000 = flowrate_gpm((1720-310)*100+1:(1840-310)*100+1);  % 1720-1840

% acceleration data & FFT
[fft_600x, fft_600y, fft_600z, f_600, data_time_600, ax_600, ay_600, az_600] = mai_fft(data(1:4, 179275:239243)); %600 gpm data 360 - 480s teensy time
[fft_1100x, fft_1100y, fft_1100z, f_1100, data_time_1100, ax_1100, ay_1100, az_1100] = mai_fft(data(1:4, 419147:479147)); %1100 gpm data 840 - 960s teensy time
[fft_1600x, fft_1600y, fft_1600z, f_1600, data_time_1600, ax_1600, ay_1600, az_1600] = mai_fft(data(1:4, 599059:659069)); %1600 gpm data 1200 - 1320s teensy time
[fft_2000x, fft_2000y, fft_2000z, f_2000, data_time_2000, ax_2000, ay_2000, az_2000] = mai_fft(data(1:4, 858963:918931)); %2000 gpm data 1720 - 1840s teensy time



%% Plotting 600 GPM
figure(1)
subplot(5,4,1);
hold on
plot(flowrate_time_600, flowrate_gpm_600)
title('Flowrate 600GPM')
xlabel('Time(s)')
ylabel('GPM')

subplot(5,4,5);
hold on
plot(data_time_600, ax_600)
plot(data_time_600, ay_600)
plot(data_time_600, az_600)
title('Time Series of 600 GPM With Gravity Removed')
xlabel('time (s)') 
ylabel('Acceleration (g)') 
legend('acceleration_x','acceleration_y','acceleration_z')

subplot(5,4,9); 
plot(f_600,fft_600x) 
title('X axis Frequency Domain of 600 GPM')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
ylim([0,0.01])

subplot(5,4,13); 
plot(f_600,fft_600y) 
title('Y axis Frequency Domain of 600 GPM')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
ylim([0,0.01])

subplot(5,4,17); 
plot(f_600,fft_600z) 
title('Z axis Frequency Domain of 600 GPM')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
ylim([0,0.01])

%% Plotting 1100 GPM
%figure(2)
subplot(5,4,2);
hold on
plot(flowrate_time_1100, flowrate_gpm_1100)
title('Flowrate 1100GPM')
xlabel('Time(s)')
ylabel('GPM')

subplot(5,4,6);
hold on
plot(data_time_1100, ax_1100)
plot(data_time_1100, ay_1100)
plot(data_time_1100, az_1100)
title('Time Series of 1100 GPM With Gravity Removed')
xlabel('time (s)') 
ylabel('Acceleration (g)') 
legend('acceleration_x','acceleration_y','acceleration_z')

subplot(5,4,10); 
plot(f_1100,fft_1100x) 
title('X axis Frequency Domain of 1100 GPM')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
ylim([0,0.01])

subplot(5,4,14); 
plot(f_1100,fft_1100y) 
title('Y axis Frequency Domain of 1100 GPM')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
ylim([0,0.01])

subplot(5,4,18); 
plot(f_1100,fft_1100z) 
title('Z axis Frequency Domain of 1100 GPM')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
ylim([0,0.01])

%% Plotting 1600 GPM
%figure(3)
subplot(5,4,3);
hold on
plot(flowrate_time_1600, flowrate_gpm_1600)
title('Flowrate 1600GPM')
xlabel('Time(s)')
ylabel('GPM')

subplot(5,4,7);
hold on
plot(data_time_1600, ax_1600)
plot(data_time_1600, ay_1600)
plot(data_time_1600, az_1600)
title('Time Series of 1600 GPM With Gravity Removed')
xlabel('time (s)') 
ylabel('Acceleration (g)') 
legend('acceleration_x','acceleration_y','acceleration_z')

subplot(5,4,11); 
plot(f_1600,fft_1600x) 
title('X axis Frequency Domain of 1600 GPM')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
xlim([0,250])
ylim([0,0.01])

subplot(5,4,15); 
plot(f_1600,fft_1600y) 
title('Y axis Frequency Domain of 1600 GPM')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
xlim([0,250])
ylim([0,0.01])

subplot(5,4,19); 
plot(f_1600,fft_1600z) 
title('Z axis Frequency Domain of 1600 GPM')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
xlim([0,250])
ylim([0,0.01])

%% Plotting 2000 GPM
subplot(5,4,4);
hold on
plot(flowrate_time_2000, flowrate_gpm_2000)
title('Flowrate 2000GPM')
xlabel('Time(s)')
ylabel('GPM')

subplot(5,4,8);
hold on
plot(data_time_2000, ax_2000)
plot(data_time_2000, ay_2000)
plot(data_time_2000, az_2000)
title('Time Series of 2000 GPM With Gravity Removed')
xlabel('time (s)') 
ylabel('Acceleration (g)') 
legend('acceleration_x','acceleration_y','acceleration_z')

subplot(5,4,12); 
plot(f_2000,fft_2000x) 
title('X axis Frequency Domain of 2000 GPM')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
ylim([0,0.01])

subplot(5,4,16); 
plot(f_2000,fft_2000y) 
title('Y axis Frequency Domain of 2000 GPM')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
ylim([0,0.01])

subplot(5,4,20); 
plot(f_2000,fft_2000z) 
title('Z axis Frequency Domain of 2000 GPM')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
ylim([0,0.01])



function [single_FFTaccel_RMS_x, single_FFTaccel_RMS_y, single_FFTaccel_RMS_z , f, time, accel_x, accel_y, accel_z] = mai_fft(data)
time = transpose(data(1,:) ./ 1000000);
accel_x = transpose(data(2,:));
accel_y = transpose(data(3,:));
accel_z = transpose(data(4,:));

%% smooth data
accel_x = smooth(accel_x, 'loess');
accel_y = smooth(accel_y, 'loess');
accel_z = smooth(accel_z, 'loess');

%% FFT
%% Mangitude of x, y, z calibration data
%Root Mean Square (RMS) of acceleration data
%accel_RMS = sqrt((accel_x.^2)+(accel_y.^2)+(accel_z.^2));

%% FFT parameters
% desired length to calculate the fourier trans of signal
NFFT = 2^(nextpow2(length(accel_x)));
%sampling interval
dt = mean(diff(time));
%sampling frequency
Fs = 1/dt;      % unit: Hz
%Nyquist frequency
Fn = Fs/2;      % unit: Hz   
%creating a frequency vector
f = Fs*(0:(NFFT/2))/NFFT;

%% Fourier transformation of data
%Fourier transform of the signal
FFTaccel_x = fft(accel_x);
FFTaccel_y = fft(accel_y);
FFTaccel_z = fft(accel_z);


% Compute magnitude of the two-sided spectrum FFTaccel_RMS. 
two_FFTaccel_RMS_x = abs(FFTaccel_x/NFFT);
two_FFTaccel_RMS_y = abs(FFTaccel_y/NFFT);
two_FFTaccel_RMS_z = abs(FFTaccel_z/NFFT);
% Compute the single-sided spectrum based on 2-sided spectrum FFTaccel_RMS and the even-valued signal length NFFT.
% because (FFT is mirrored) and we only care about the first half of the sampling frequency
single_FFTaccel_RMS_x = two_FFTaccel_RMS_x(1:NFFT/2+1);
single_FFTaccel_RMS_x(2:end-1) = 2*single_FFTaccel_RMS_x(2:end-1);

single_FFTaccel_RMS_y = two_FFTaccel_RMS_y(1:NFFT/2+1);
single_FFTaccel_RMS_y(2:end-1) = 2*single_FFTaccel_RMS_y(2:end-1);

single_FFTaccel_RMS_z = two_FFTaccel_RMS_z(1:NFFT/2+1);
single_FFTaccel_RMS_z(2:end-1) = 2*single_FFTaccel_RMS_z(2:end-1);




% %Compute the power of the single sided discrete Fourier transform of signal
% power_single_FFTaccel_RMS = (single_FFTaccel_RMS.^2)/NFFT;


end

