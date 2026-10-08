N = 256;
nSeeds = 4000;

T = sdf_fft_data_types('double');


error = zeros(nSeeds,1);
sqnr_dB = zeros(nSeeds,1);

% Open files for writing
% fid_in  = fopen('fft_inputs.txt','w');
% fid_out = fopen('fft_outputs.txt','w');

for seed = 1:nSeeds
    rng(seed);

    x_double = randn(N,1) + 1i*randn(N,1);
    x = cast(x_double, 'like', T.x);
    
    if seed == 1
    buildInstrumentedMex sdf_fft -args {x, T};
    end
    
    y = sdf_fft_mex(x, T);
    
    %bitreversal
    y_ref = fft(x_double);
    perm  = bitrevorder(0:N-1);
    yCorrected = zeros(N,1);
    yCorrected(perm+1) = y;

    error(seed) = mean(abs(yCorrected - y_ref));
    signal_power   = mean(abs(y_ref).^2);
    noise_power    = mean(abs(yCorrected - y_ref).^2);
    sqnr_dB(seed)  = 10*log10(signal_power / noise_power);
    
    % Write inputs and outputs to files
%     for k = 1:N
%         % Input: real and imag parts in hex (signed floating point)
%         in_real_hex = hex(real(x(k)));
%         in_imag_hex = hex(imag(x(k)));
% 
%         % Output: bit-reversed order, real and imag parts in hex
%         out_real_hex = hex(real(y(k)));
%         out_imag_hex = hex(imag(y(k)));
% 
%         % Write to files (each line: real_hex imag_hex)
%         fprintf(fid_in,  '%s %s\n', in_real_hex, in_imag_hex);
%         fprintf(fid_out, '%s %s\n', out_real_hex, out_imag_hex);
%     end
end

% fclose(fid_in);
% fclose(fid_out);

% write_twiddles_hex(T, N);

avg_error   = mean(error);
avg_sqnr_dB = mean(sqnr_dB);

fprintf('average error = %e\n', avg_error);
fprintf('average sqnr = %.2f dB\n', avg_sqnr_dB);

figure; plot(1:nSeeds, error, 'LineWidth', 2); grid on;
xlabel('Seed', 'FontSize', 14); ylabel('Error', 'FontSize', 14);

figure; plot(1:nSeeds, sqnr_dB, 'LineWidth', 2); grid on;
xlabel('Seed', 'FontSize', 14); ylabel('SQNR (dB)', 'FontSize', 14);
showInstrumentationResults sdf_fft_mex