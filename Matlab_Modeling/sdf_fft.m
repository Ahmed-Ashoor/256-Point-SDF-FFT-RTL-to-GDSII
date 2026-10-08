function y = sdf_fft(x, T) %#codegen

N  = 256;
x  = cast(x, 'like', T.x);

% twiddle ROM in hardware
idxVec         = (0:127).';
twTable_double = exp(-1i * 2 * pi * idxVec / N);   % double
twTable        = cast(twTable_double, 'like', T.WN);   % casting


%stage 1: period=256, half=128, exponent step = 2^0 = 1
stg_1 = cast(complex(zeros(256,1)), 'like', T.stg1);
for i = 1:256
    if i <= 128
        stg_1(i) = cast(x(i) + x(i + 128), 'like', T.stg1);
    else
        n  = i - 129;
        Wp = twTable(n + 1);           % WN^(1*n)
        stg_1(i) = cast((x(i - 128) - x(i)) * Wp, 'like', T.stg1);
    end
end

%stage 2: period=128, half=64, exponent step = 2^1 = 2
stg_2 = cast(complex(zeros(256,1)), 'like', T.stg2);
for i = 1:256
    p = mod(i-1, 128);
    if p < 64
        stg_2(i) = cast(stg_1(i) + stg_1(i + 64), 'like', T.stg2);
    else
        n  = p - 64;
        Wp = twTable(2*n + 1);         % WN^(2*n)
        stg_2(i) = cast((stg_1(i - 64) - stg_1(i)) * Wp, 'like', T.stg2);
    end
end

%stage 3: period=64, half=32, exponent step = 2^2 = 4
stg_3 = cast(complex(zeros(256,1)), 'like', T.stg3);
for i = 1:256
    p = mod(i-1, 64);
    if p < 32
        stg_3(i) = cast(stg_2(i) + stg_2(i + 32), 'like', T.stg3);
    else
        n  = p - 32;
        Wp = twTable(4*n + 1);         % WN^(4*n)
        stg_3(i) = cast((stg_2(i - 32) - stg_2(i)) * Wp, 'like', T.stg3);
    end
end

%stage 4: period=32, half=16, exponent step = 2^3 = 8
stg_4 = cast(complex(zeros(256,1)), 'like', T.stg4);
for i = 1:256
    p = mod(i-1, 32);
    if p < 16
        stg_4(i) = cast(stg_3(i) + stg_3(i + 16), 'like', T.stg4);
    else
        n  = p - 16;
        Wp = twTable(8*n + 1);         % WN^(8*n)
        stg_4(i) = cast((stg_3(i - 16) - stg_3(i)) * Wp, 'like', T.stg4);
    end
end

%stage 5: period=16, half=8, exponent step = 2^4 = 16
stg_5 = cast(complex(zeros(256,1)), 'like', T.stg5);
for i = 1:256
    p = mod(i-1, 16);
    if p < 8
        stg_5(i) = cast(stg_4(i) + stg_4(i + 8), 'like', T.stg5);
    else
        n  = p - 8;
        Wp = twTable(16*n + 1);        % WN^(16*n)
        stg_5(i) = cast((stg_4(i - 8) - stg_4(i)) * Wp, 'like', T.stg5);
    end
end

%stage 6: period=8, half=4, exponent step = 2^5 = 32
stg_6 = cast(complex(zeros(256,1)), 'like', T.stg6);
for i = 1:256
    p = mod(i-1, 8);
    if p < 4
        stg_6(i) = cast(stg_5(i) + stg_5(i + 4), 'like', T.stg6);
    else
        n  = p - 4;
        Wp = twTable(32*n + 1);        % WN^(32*n)
        stg_6(i) = cast((stg_5(i - 4) - stg_5(i)) * Wp, 'like', T.stg6);
    end
end

%stage 7: period=4, half=2, exponent step = 2^6 = 64
stg_7 = cast(complex(zeros(256,1)), 'like', T.stg7);
for i = 1:256
    p = mod(i-1, 4);
    if p < 2
        stg_7(i) = cast(stg_6(i) + stg_6(i + 2), 'like', T.stg7);
    else
        n  = p - 2;
        Wp = twTable(64*n + 1);        % WN^(64*n)
        stg_7(i) = cast((stg_6(i - 2) - stg_6(i)) * Wp, 'like', T.stg7);
    end
end

%stage 8: period=2, half=1 (twiddle always 1 -- no multiply/cast needed)
stg_8 = cast(complex(zeros(256,1)), 'like', T.stg8);
for i = 1:256
    p = mod(i-1, 2);
    if p < 1
        stg_8(i) = cast(stg_7(i) + stg_7(i + 1), 'like', T.stg8);
    else
        stg_8(i) = cast(stg_7(i - 1) - stg_7(i), 'like', T.stg8);
    end
end

y = cast(stg_8, 'like', T.y);

end