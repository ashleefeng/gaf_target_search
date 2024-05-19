% utility function for ThreeColorDat2States.m
% Jan 6, 2023 X. Feng

function s = which_state(y0, y1, y2, u0, u1, u2, num_std)
    snr0 = abs(y0) / u0;
    snr1 = abs(y1) / u1;
    snr2 = abs(y2) / u2;
    
    %u_sum = sqrt(u0 ^ 2 + u1 ^ 2 + u2 ^ 2);
    %y_sum = y0 + y1 + y2;
    %snr_sum = y_sum / u_sum;
    
    if (snr1 > num_std && y1 > 0) || (snr2 > num_std && y2 > 0)
        if y1 > y2
            s = 1;
        else
            s = 2;
        end
    elseif y0 > 0 && snr0 > num_std
        s = 0;
    else
        s = 3;
    end
end