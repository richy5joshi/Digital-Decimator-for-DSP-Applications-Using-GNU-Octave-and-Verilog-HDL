clc;
clear;
close all;

%% ============================================================
%  DIGITAL DECIMATOR PROJECT - INPUT SIGNAL GENERATION
%  GNU Octave
% =============================================================

%% 1. PARAMETERS

Fs   = 100e6;       % Sampling frequency = 100 MHz
Fsig = 5e6;         % Input sine-wave frequency = 5 MHz
N    = 400;         % Number of input samples
D    = 4;           % Decimation factor
BITS = 16;          % ADC/sample resolution

MAX_VALUE = 2^(BITS-1) - 1;


%% ============================================================
% 2. CONTINUOUS / ANALOG-LIKE SINE WAVE
% =============================================================

% Fine time axis for continuous-looking waveform
t_cont = linspace(0, (N-1)/Fs, N*20);

% Continuous sine wave
x_cont = sin(2*pi*Fsig*t_cont);


%% ============================================================
% 3. DISCRETE-TIME SINE SIGNAL
% =============================================================

% Discrete sample index
n = 0:N-1;

% Discrete-time sine signal
x = sin(2*pi*Fsig/Fs*n);


%% ============================================================
% 4. QUANTIZE TO 16-BIT SIGNED INTEGER
% =============================================================

x_q = round(x * MAX_VALUE);


%% ============================================================
% 5. PLOT ANALOG + DISCRETE SIGNAL
% =============================================================

figure;

plot(t_cont*1e6, x_cont, 'LineWidth', 1.5);
hold on;

stem(n(1:80)/Fs*1e6, x(1:80), 'filled');

grid on;

title('Analog and Discrete-Time Sine Signal');

xlabel('Time (\mus)');
ylabel('Amplitude');

legend('Continuous / Analog Reference', ...
       'Discrete Samples');

hold off;


%% ============================================================
% 6. PLOT DIGITAL / QUANTIZED SIGNAL
% =============================================================

figure;

stem(n(1:80), x_q(1:80), 'filled');

grid on;

title('16-bit Quantized Digital Input Signal');

xlabel('Sample Index n');
ylabel('Digital Amplitude');



%% ============================================================
% 7. IDEAL DECIMATION BY 4
% =============================================================

% Keep every 4th sample
y_expected = x_q(1:D:end);


%% ============================================================
% 8. PLOT EXPECTED DECIMATED OUTPUT
% =============================================================

m = 0:length(y_expected)-1;

figure;

stem(m(1:20), y_expected(1:20), 'filled');

grid on;

title('Expected Decimator Output (Decimation Factor = 4)');

xlabel('Output Sample Index m');
ylabel('Amplitude');



%% ============================================================
% 9. CREATE input_data.txt
% =============================================================

fid = fopen('input_data.txt', 'w');

for i = 1:length(x_q)

    fprintf(fid, '%d\n', x_q(i));

end

fclose(fid);



%% ============================================================
% 10. CREATE input_data.mem
% ============================================================

fid = fopen('input_data.mem', 'w');

for i = 1:length(x_q)

    % Convert signed 16-bit value to hexadecimal
    value = mod(x_q(i), 65536);

    fprintf(fid, '%04X\n', value);

end

fclose(fid);



%% ============================================================
% 11. CREATE EXPECTED OUTPUT FILE
% =============================================================

fid = fopen('expected_output.mem', 'w');

for i = 1:length(y_expected)

    fprintf(fid, '%d\n', y_expected(i));

end

fclose(fid);



%% ============================================================
% 12. DISPLAY INFORMATION
% =============================================================

fprintf('\n============================================\n');
fprintf(' DECIMATOR INPUT DATA GENERATED\n');
fprintf('============================================\n');

fprintf('Sampling Frequency : %.2f MHz\n', Fs/1e6);
fprintf('Signal Frequency   : %.2f MHz\n', Fsig/1e6);
fprintf('Number of Samples  : %d\n', N);
fprintf('Data Width         : %d bits\n', BITS);
fprintf('Decimation Factor  : %d\n', D);

fprintf('\nInput Samples       : %d\n', length(x_q));
fprintf('Output Samples      : %d\n', length(y_expected));

fprintf('\nOutput Sampling Frequency = %.2f MHz\n', ...
        Fs/(D*1e6));

fprintf('\nFiles Generated:\n');
fprintf('  input_data.txt\n');
fprintf('  input_data.mem\n');
fprintf('  expected_output.txt\n');

fprintf('============================================\n');
