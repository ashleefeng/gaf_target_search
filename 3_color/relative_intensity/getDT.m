% Utility function for ThreeColorDat2States.m
% Jan 8, 2023 X. Feng
%
% Extract a list of dwell times for a specified state
% Assumes input filtered_state_list has been processed by bd_filter
%
% Input: 
%
% state_list - 1D list of values 0, 1, 2 or 3
% state - state value (0, 1, or 2) to extract dwell times for
% time_unit - exposure time of each data point
% 
% Output:
%
% dt_list - 1D list of dwell times for the specified state in the given 
%           binding event in state_list

function dt_list = getDT(filtered_state_list, state, time_unit)
    
    dt_list = [];
    curr_start = 1;
    curr_end = 0;
    counting = 0;
    prev_s = -1;

    for i = 1: length(filtered_state_list)
        
        s = filtered_state_list(i);
        
        if (s ~= 3) || (prev_s ~= 3)
            
            % scanning for desired state, update pointers only
            
            if (s ~= state) && (counting == 0)
                
                curr_start = i + 1;
                curr_end = i;                
            
            % current dt ends, update dt_list
            
            elseif (s ~= state) && (counting == 1)
                
                curr_dt = time_unit * (curr_end -  curr_start + 1);
                dt_list = [dt_list curr_dt];
                
                counting = 0;
                curr_start = i + 1;
                curr_end = i;
            
            % update current dt
            
            else
                
                curr_end = curr_end + 1;
                counting = 1;
            end
        else
            
            curr_start = i + 1;
            curr_end = i;
        end      
        
        prev_s = s;
    end

end