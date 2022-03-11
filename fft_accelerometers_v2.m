%% load digital acceleration signal
%sampled data [r x 4] 
filename = 'handheld.csv';
signal =readtable(filename);  

%% Create new time array
%define time cell array: signal.time
%convert cell array from "mm:ss.SS" format to duration: duration(signal.time,"InputFormat","mm:ss.SS")
%new numeric time array (in seconds)
t_secs = seconds(duration(signal.time,"InputFormat","mm:ss.SS"));
%create a new time vector of time difference
time = t_secs - (t_secs(1,1));

%% Mangitude of x, y, z calibration data
%table of 3 acceleration columns
accel_table = signal(:,2:end);
%Convert table to individual arrays
accel_matrix = table2array(accel_table);
%define individual acceleration array
accel_x = accel_matrix(:,1);
accel_y = accel_matrix(:,2);
accel_z = accel_matrix(:,3);
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

subplot(3,1,3); 
plot(f,power_single_FFTaccel_RMS) 
title('Single-sided frequency spectrum of FFT signal')
xlabel('Frequency (Hz)')
ylabel('Power')
