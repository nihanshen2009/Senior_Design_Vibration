close all; 

%% load digital audio signal
%sampled data (signal) and sample rate (Fs)
filename = 'Data/wav_file.wav';
[signal,Fs]=audioread(filename);  

%% FFT parameters
% desired length to calculate the fourier trans of signal
% NFFT= length(signal);
NFFT= 2^(nextpow2(length(signal)));


%% Fourier transformation of data
%Amplitude of discrete Fourier transform of signal
fft_signal = abs(fft(signal,NFFT)); 
%Power of discrete Fourier transform of signal
power_fft_signal = (fft_signal.^2)/NFFT;

%% Initialize time and frequency domain variables
%time increment per sample
dt = 1/Fs;
%frequency increment
ft = Fs/NFFT;
%creating a time vector: t = linspace(start time, end time, # of samples in data)
t = linspace(0, (length(signal)/Fs)-1, length(signal)); %(unit: seconds)
%creating a frequency vector: f = linspace(start time, end time, length of freq vector)
f = (ft)*(linspace(0, Fs, NFFT)); %(unit: Hz)

%% Plotting time waveform and frequency spectrum of the audio signal
figure(1)
subplot(2,1,1);
plot(t, signal)
title('Time waveform of signal')
xlabel('time (s)') 
ylabel('Amplitude') 

subplot(2,1,2); 
plot(f,power_fft_signal)
title('Frequency spectrum of signal')
xlabel('Frequency (Hz)')
ylabel('Power')


%check%
disp('here');
