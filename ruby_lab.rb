#!/usr/bin/ruby

###############################################################
#
# CSCI 305 - Ruby Programming Lab
#
# Austin Rosenbaum
# austinjrosenbaum@gmail.com
#
###############################################################

$bigrams = Hash.new # The Bigram data structure
$name = "Austin Rosenbaum"

# function to process each line of a file and extract the song titles
def process_file(file_name)
	puts "Processing File.... "

	begin
		IO.foreach(file_name) do |line|
			# do something for each line
			# use regexp to remove junk before the title
			before_title_re = /.*>/
			line = line.sub!(before_title_re, "")
			title = line
			
			# us regexp to remove junk after main song title
			after_title_re = /(\(|\[|\{|\\|\/|_|-|:|"|`|\+|=|\*|feat\.).*/
			match = title.scan(after_title_re).to_s
			
			# blank matches are clearing entire line, so check that something was matched
			if match != "[]"
				title = title.sub!(after_title_re, "")
			end
			
			# Remove punctuation from titles, perform global replace (gsub!)
			
			# Remove non english characters
			
			# set to lowercase
			title.downcase
			
			
			puts title
		end

		puts "Finished. Bigram model built.\n"
	rescue
		STDERR.puts "Could not open file"
		exit 4
	end
end

# Executes the program
def main_loop()
	puts "CSCI 305 Ruby Lab submitted by #{$name}"

	if ARGV.length < 1
		puts "You must specify the file name as the argument."
		exit 4
	end

	# process the file
	process_file(ARGV[0])

	# Get user input
end

main_loop()
