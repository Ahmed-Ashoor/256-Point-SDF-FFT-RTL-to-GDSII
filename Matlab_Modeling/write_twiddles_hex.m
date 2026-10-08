function write_twiddles_hex(T, N)
% Dump twiddle factors for each FFT stage into separate text files in hex.
% Inputs:
%   T : struct with field WN (type info for casting)
%   N : FFT length (e.g. 256)

    % Build twiddle table
    idxVec         = (0:(N/2 - 1)).';
    twTable_double = exp(-1i * 2 * pi * idxVec / N);
    twTable        = cast(twTable_double, 'like', T.WN);

    % Helper to write one twiddle in hex
    function write_twiddle(fid, W)
        re_hex = hex(real(W));
        im_hex = hex(imag(W));
        fprintf(fid, '%s%s\n', re_hex, im_hex);
    end

    % Loop over stages 1..log2(N)-1 (stage 8 has no twiddles)
    for stage = 1:log2(N)-1
        half = N / (2^stage);
        step = 2^(stage-1);

        fname = sprintf('stg_%d_factors_rom.txt', stage);
        fid = fopen(fname,'w');

        for n = 0:(half-1)
            Wp = twTable(step*n + 1);
            write_twiddle(fid,Wp);
        end

        fclose(fid);
    end
end
