function i = sample(log,line) 

    time_zero = time(log,1);
    
    i = int32((time(log, line) - time_zero)*100) + 1;
    
end



