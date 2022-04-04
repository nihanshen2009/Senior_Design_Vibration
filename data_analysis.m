clear
clc
%% Read Byte File to Raw Data
raw_time_file_name = "Data/stem nut.txt";
fileID = fopen(raw_time_file_name, 'r')
file_dir = dir(raw_time_file_name)
size = file_dir.bytes % size of file in bytes
raw_data = fread(fileID, [4, size], 'int');
raw_data = raw_data((1:4),(33:size/4/4)); % trimming off zeros

%% Convert Raw Data to G's
conversion_factor = .0002441407513657033; % from arduino code (Yigit Testified)
data(1,:) = raw_data(1,:);
data(2:4,:) = raw_data(2:4,:).* conversion_factor;


%% Hard Dividing data to different flowrate zones
% [fft_data, f, data_time, ax, ay, az] = mai_fft(data); %entire dataset
[fft_600, f_600, data_time_600, ax_600, ay_600, az_600] = mai_fft(data(1:4, 179275:239243)); %600 gpm data
[fft_1100, f_1100, data_time_1100, ax_1100, ay_1100, az_1100] = mai_fft(data(1:4, 419147:479147)); %1100 gpm data
[fft_1600, f_1600, data_time_1600, ax_1600, ay_1600, az_1600] = mai_fft(data(1:4, 599059:659069)); %1600 gpm data
[fft_2000, f_2000, data_time_2000, ax_2000, ay_2000, az_2000] = mai_fft(data(1:4, 858963:918931)); %2000 gpm data

%% Plotting 600 GPM
figure(1)
subplot(2,4,1);
hold on
plot(data_time_600, ax_600)
plot(data_time_600, ay_600)
plot(data_time_600, az_600)
title('Time Series of 600 GPM')
xlabel('time (s)') 
ylabel('Acceleration (g)') 
legend('acceleration_x','acceleration_y','acceleration_z')

subplot(2,4,5); 
plot(f_600,fft_600) 
title('Frequency Domain of 600 GPM')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
ylim([0,0.01])

%% Plotting 1100 GPM
%figure(2)
subplot(2,4,2);
hold on
plot(data_time_1100, ax_1100)
plot(data_time_1100, ay_1100)
plot(data_time_1100, az_1100)
title('Time Series of 1100 GPM')
xlabel('time (s)') 
ylabel('Acceleration (g)') 
legend('acceleration_x','acceleration_y','acceleration_z')

subplot(2,4,6); 
plot(f_1100,fft_1100) 
title('Frequency Domain of 1100 GPM')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
ylim([0,0.05])

%% Plotting 1600 GPM
%figure(3)
subplot(2,4,3);
hold on
plot(data_time_1600, ax_1600)
plot(data_time_1600, ay_1600)
plot(data_time_1600, az_1600)
title('Time Series of 1600 GPM')
xlabel('time (s)') 
ylabel('Acceleration (g)') 
legend('acceleration_x','acceleration_y','acceleration_z')

subplot(2,4,7); 
plot(f_1600,fft_1600) 
title('Frequency Domain of 1600 GPM')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
ylim([0,0.01])

%% Plotting 2000 GPM
%figure(4)
subplot(2,4,4);
hold on
plot(data_time_2000, ax_2000)
plot(data_time_2000, ay_2000)
plot(data_time_2000, az_2000)
title('Time Series of 2000 GPM')
xlabel('time (s)') 
ylabel('Acceleration (g)') 
legend('acceleration_x','acceleration_y','acceleration_z')

subplot(2,4,8); 
plot(f_2000,fft_2000) 
title('Frequency Domain of 600 GPM')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
ylim([0,0.01])


function [single_FFTaccel_RMS, f, time, accel_x, accel_y, accel_z] = mai_fft(data)
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
accel_RMS = sqrt((accel_x.^2)+(accel_y.^2)+(accel_z.^2));

%% FFT parameters
% desired length to calculate the fourier trans of signal
NFFT = 2^(nextpow2(length(accel_RMS)));
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
FFTaccel_RMS = fft(accel_RMS);
% Compute magnitude of the two-sided spectrum FFTaccel_RMS. 
two_FFTaccel_RMS = abs(FFTaccel_RMS/NFFT);
% Compute the single-sided spectrum based on 2-sided spectrum FFTaccel_RMS and the even-valued signal length NFFT.
% because (FFT is mirrored) and we only care about the first half of the sampling frequency
single_FFTaccel_RMS = two_FFTaccel_RMS(1:NFFT/2+1);
single_FFTaccel_RMS(2:end-1) = 2*single_FFTaccel_RMS(2:end-1);

% %Compute the power of the single sided discrete Fourier transform of signal
% power_single_FFTaccel_RMS = (single_FFTaccel_RMS.^2)/NFFT;


end

