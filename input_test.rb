MEGABYTE = 1024*1024
$num_lines = 0

def process_file(file)


  #file.read(size) returns a string of length 'size'
  #size of unique_tracks.txt = 85049344
  File.open(file) do |f|
    split_string(f.read(85049344)) until f.eof?
  end
  puts "Total lines read: #{$num_lines}"

end

def split_string(str)
  arr = str.split("\n")
  arr.each do |line|
    $num_lines += 1
  end
end

process_file(ARGV[0])
