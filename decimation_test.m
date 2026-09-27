clc;
clear;
close all;

%% PARAMETERS

Fs = 100e6;
Fsig = 5e6;
D = 4;
Fs_out = Fs / D;

BITS = 16;
MAX_VALUE = 2^(BITS-1) - 1;

N = 400;


%% READ ACTUAL VERILOG OUTPUT

filename = 'actual_decimated_output.mem';

fid = fopen(filename, 'r');

if fid == -1
    error('Cannot find actual_decimated_output.mem');
end

hex_data = textscan(fid, '%s');

fclose(fid);

hex_data = hex_data{1};


%% CHECK FILE

fprintf('\nNumber of HEX values read = %d\n', length(hex_data));

if isempty(hex_data)

    error(['actual_decimated_output.mem is EMPTY. ' ...
           'Check the Verilog testbench output file.']);

end


%% HEX TO DECIMAL

actual_decimated = hex2dec(hex_data);


%% CONVERT UNSIGNED 16-BIT TO SIGNED

actual_decimated(actual_decimated >= 32768) = ...
    actual_decimated(actual_decimated >= 32768) - 65536;

actual_decimated = double(actual_decimated);


%% GENERATE EXPECTED INPUT

n = 0:N-1;

x = sin(2*pi*Fsig/Fs*n);

x_q = round(x * MAX_VALUE);


%% IDEAL DECIMATION

expected_decimated = x_q(1:D:end);


%% SAMPLE COUNT CHECK

fprintf('\n============================================\n');
fprintf('       DECIMATOR VERIFICATION\n');
fprintf('============================================\n');

fprintf('Expected Samples : %d\n', ...
        length(expected_decimated));

fprintf('Actual Samples   : %d\n', ...
        length(actual_decimated));


if length(actual_decimated) == length(expected_decimated)

    fprintf('Sample Count Verification : PASS\n');

else

    fprintf('Sample Count Verification : FAIL\n');

end


%% COMPARE

min_length = min( ...
    length(actual_decimated), ...
    length(expected_decimated));


actual_compare = ...
    actual_decimated(1:min_length);

expected_compare = ...
    expected_decimated(1:min_length);


%% ERROR

error_signal = ...
    actual_compare - expected_compare;


max_error = max(abs(error_signal));


fprintf('\n--------------------------------------------\n');

fprintf('Maximum Absolute Error : %d\n', max_error);


if max_error == 0

    fprintf('DECIMATOR VERIFICATION : PASS\n');

else

    fprintf('DECIMATOR VERIFICATION : FAIL\n');

end

fprintf('--------------------------------------------\n');


%% FIND MISMATCHES

mismatch_index = find(error_signal ~= 0);

fprintf('Number of Mismatched Samples : %d\n', ...
        length(mismatch_index));


%% PLOT ONLY IF DATA EXISTS

if min_length > 0

    m = 0:min_length-1;

    %% Expected vs Actual

    figure;

    stem(m, expected_compare / MAX_VALUE, 'filled');

    hold on;

    stem(m, actual_compare / MAX_VALUE);

    grid on;

    xlabel('Output Sample Index');

    ylabel('Normalized Amplitude');

    title('Expected vs Actual Decimator Output');

    legend('Expected', 'Actual');

    hold off;


    %% Error

    figure;

    stem(m, error_signal, 'filled');

    grid on;

    xlabel('Output Sample Index');

    ylabel('Error');

    title('Decimator Output Error');


    %% Actual Decimated Signal

    t_actual = m / Fs_out;

    figure;

    stem(t_actual * 1e6, ...
         actual_compare / MAX_VALUE, ...
         'filled');

    grid on;

    xlabel('Time (\mus)');

    ylabel('Normalized Amplitude');

    title('Actual Decimated Signal from Verilog RTL');

end


%% FINAL RESULT

fprintf('\n============================================\n');

if max_error == 0 && ...
   length(actual_decimated) == length(expected_decimated)

    fprintf('FINAL RESULT : VERIFICATION SUCCESSFUL\n');

else

    fprintf('FINAL RESULT : VERIFICATION FAILED\n');

end

fprintf('============================================\n');
