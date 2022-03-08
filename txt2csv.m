raw_time_file_name = "datalog.txt";

fileID = fopen(raw_time_file_name, 'r')

file_dir = dir(raw_time_file_name)
size = file_dir.bytes

fread(fileID, size, 'int')


