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

%% smooth data
accel_x = smooth(accel_x, 'loess');
accel_y = smooth(accel_y, 'loess');
accel_z = smooth(accel_z, 'loess');

%smooth_x = lowpass(accel_x, 0.99);

%{
figure(1)
subplot(2,1,1);
plot(accel_x)
title('accel_x')

subplot(2,1,2);
plot(smooth_x)
title('smooth_x')
%}

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

%Compute the power of the single sided discrete Fourier transform of signal
power_single_FFTaccel_RMS = (single_FFTaccel_RMS.^2)/NFFT;


%% Plotting time waveform and frequency spectrum of the audio signal
figure(1)
subplot(3,1,1);
plot(time, accel_x)
hold on
plot(time, accel_y)
plot(time, accel_z)
title('Time waveform of signal')
xlabel('time (s)') 
ylabel('Amplitude') 
legend('acceleration_x','acceleration_y','acceleration_z')

subplot(3,1,2); 
plot(f,single_FFTaccel_RMS) 
title('Single-sided frequency spectrum of FFT signal')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
ylim([0,0.01])

subplot(3,1,3); 
plot(f,power_single_FFTaccel_RMS) 
title('Single-sided frequency spectrum of FFT signal')
xlabel('Frequency (Hz)')
ylabel('Power')


