% Takes array in form of YEAR-M-DDT01:23:45.678Z and extracts seconds cut
% off at hundreths place by multiplying to get a magnitude.

function seconds = time(log,line)

    text = char(log(line,1));
    
    hour = 10* str2num(text(12)) + str2num(text(13));
    minute = 10* str2num(text(15)) + str2num(text(16));
    second = 10* str2num(text(18)) + str2num(text(19));
    thousandth = 100* str2num(text(21)) + 10* str2num(text(22));
    
    seconds = 3600*hour + 60*minute + second + 1/1000*thousandth;

end