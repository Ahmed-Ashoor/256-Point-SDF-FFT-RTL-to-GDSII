function T = sdf_fft_data_types(dt)
% dt: 'double' or 'single' (extend with fixed-point cases as needed)


switch dt
    case 'double'
        T.x    = double([]);
        T.WN   = double([]);
        T.stg1 = double([]);
        T.stg2 = double([]);
        T.stg3 = double([]);
        T.stg4 = double([]);
        T.stg5 = double([]);
        T.stg6 = double([]);
        T.stg7 = double([]);
        T.stg8 = double([]);
        T.y    = double([]);

    case 'single'
        T.x    = single([]);
        T.WN   = single([]);
        T.stg1 = single([]);
        T.stg2 = single([]);
        T.stg3 = single([]);
        T.stg4 = single([]);
        T.stg5 = single([]);
        T.stg6 = single([]);
        T.stg7 = single([]);
        T.stg8 = single([]);
        T.y    = single([]);
        
    case 'FxPt'
        %using a custom fimath to match the rtl truncating of bits instead
        %of default rounding to nearest
        fm = fimath('RoundingMethod','Floor');
        T.x    = fi([], 1, 4+12, 12, fm);
        T.WN   = fi([], 1, 2+22, 22, fm);
        T.stg1 = fi([], 1, 4+20, 20, fm);
        T.stg2 = fi([], 1, 5+19, 19, fm);
        T.stg3 = fi([], 1, 5+19, 19, fm);
        T.stg4 = fi([], 1, 6+18, 18, fm);
        T.stg5 = fi([], 1, 6+18, 18, fm);
        T.stg6 = fi([], 1, 7+17, 17, fm);
        T.stg7 = fi([], 1, 7+17, 17, fm);
        T.stg8 = fi([], 1, 8+16, 16, fm);
        T.y    = fi([], 1, 8+8, 8, fm);
end

end