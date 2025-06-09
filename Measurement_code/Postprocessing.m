data = readlines('Measured_data.txt'); %replace with full path if it does not work

begin_cutoff = 0; %amount of samples to skip in the beginning, if the system was still heating for example.
n = length(data);
t = zeros(n-begin_cutoff,1);
temp1 = zeros(n-begin_cutoff,1);
temp2 = zeros(n-begin_cutoff,1);

for i = 1:(n-begin_cutoff)
    parts = split(data(i+begin_cutoff), ',');
    t(i) = str2double(erase(parts(1), 't='));
    temp1(i) = str2double(parts(2));
    temp2(i) = str2double(parts(3));
end

avgTemp = (temp1 + temp2) / 2;

plot(t, temp1, '-r', t, temp2, '-b', t, avgTemp, '-k')
legend('Temperature top sensor', 'Temperature bottom sensor', 'Average')
xlabel('Time (s)')
ylabel('Temperature (°C)')
title('Measured temeprature over time')
grid on
