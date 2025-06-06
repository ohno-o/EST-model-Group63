port = 'COM5'; %Change this to where the arduino is connected
baudRate = 9600; %leave this

s = serialport(port, baudRate);
fileID = fopen('Measured_data.txt', 'a'); 

disp("Logging data. Press Ctrl+C to stop.");

try
    while true
        SerialData = readline(s);
        fprintf(fileID, "%s\n", SerialData);
    end
catch
    disp("Logging stopped.");A
    fclose(fileID);
end
