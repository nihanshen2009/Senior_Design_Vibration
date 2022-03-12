%% load digital audio signal
%sampled data (signal) and sample rate (Fs)
filename = 'Data/PinkPanther30.wav';
[signal,Fs]=audioread(filename);  

%% FFT parameters
% desired length to calculate the fourier trans of signal
% NFFT= length(signal);
NFFT= 2^(nextpow2(length(signal)));

%% Fourier transformation of data
%Fourier transform of the signal
FFTsignal = fft(signal);
% Compute magnitude of the two-sided spectrum FFTsignal. 
two_FFTsignal = abs(FFTsignal/NFFT);
% Compute the single-sided spectrum based on 2-sided spectrum FFTsignal and the even-valued signal length NFFT.
% because (FFT is mirrored) and we only care about the first half of the sampling frequency
single_FFTsignal = two_FFTsignal(1:NFFT/2+1);
single_FFTsignal(2:end-1) = 2*single_FFTsignal(2:end-1);
%Compute the power of the single sided discrete Fourier transform of signal
power_single_FFTsignal = (single_FFTsignal.^2)/NFFT;

%% Initialize time and frequency domain variables
%time increment per sample
dt = 1/Fs;
%frequency increment
ft = Fs/NFFT;
%creating a time vector: t = linspace(start time, end time, # of samples in data)
t = linspace(0, (length(signal)/Fs)-1, length(signal)); %(unit: seconds)
%creating a frequency vector: f = linspace(start time, end time, length of freq vector)
f = (ft)*(0:(NFFT/2)); %(unit: Hz)

%% Plotting time waveform and frequency spectrum of the audio signal
figure(1)
subplot(3,1,1);
plot(t, signal)
title('Time waveform of signal')
xlabel('time (s)') 
ylabel('Amplitude') 

subplot(3,1,2); 
plot(f,single_FFTsignal) 
title('Single-sided frequency spectrum of FFT signal')
xlabel('Frequency (Hz)')
ylabel('Magnitude')

subplot(3,1,3); 
plot(f,power_single_FFTsignal) 
title('Single-sided frequency spectrum of FFT signal')
xlabel('Frequency (Hz)')
ylabel('Power')


