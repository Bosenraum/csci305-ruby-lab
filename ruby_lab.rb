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

# Debugging variables
# $num_lines = 0
# $total_lines = 0

# function to process each line of a file and extract the song titles
def process_file(file_name)
	puts "Processing File.... "

	# The array of all stop words to be filtered out
	stop_words = %w{a an and by for from in of on or out the to with}

	begin
		#IO.foreach(file_name) do |line|

		# I'm reading the file in differently here to correctly get the full file.
		# I was having problems with unique_tracks not processing fully, but the code
		# below fixes this problem

		line_arr = Array.new		# create array to hold lines
		file_size = File.new(file_name).size		# extract the size of the file in MB

		#puts "#{file_name} is #{file_size} bytes long"		# debugging string

		# Open the file and read in "chunks", but one chunck is the full file size
		# Looking for the exact file size allows the file to be read properly
		File.open(file_name) do |f|
			line_arr = split_string(f.read(file_size)) until f.eof?		# Save to array of lines
		end

		# Main processing for each line
		line_arr.each do |line|
			line += "\n"	# Add the endline character back after spliting on it

			# Force the encoding to utf-8 to avoid issues with non english characters
			line.force_encoding 'utf-8'

			# do something for each line
			# use regexp to remove junk before the title
			before_title_re = /.*>/
			line.sub!(before_title_re, "")
			title = line

			# us regexp to remove junk after main song title
			after_title_re = /(\(|\[|\{|\\|\/|_|-|:|"|`|\+|=|\*|feat\.).*/
			title.sub!(after_title_re, "")

			# Remove punctuation from titles, perform global replace (gsub!)
			# Remove ? ¿ ! ¡ . ; & @ % # |
			punc_re = /(\?|¿|!|¡|\.|;|&|@|%|#|\|)/
			title.gsub!(punc_re, "")

			# Remove non english characters by finding all lines with only desired characters
			english_re = /^(\w|'|\s)+\n$/
			if line =~ english_re
				valid = true
			else
				# If the line contains non english characters, set it to nil and change
				# the valid flag to false
				valid = false
				line = nil
			end

			# Only continue processing if valid is true

			# set to lowercase
			title.downcase! if valid

			# For debugging
			#$num_lines += 1 if valid
			#$total_lines += 1

			# Create bi-gram count from valid words
			# begin by spliting into individual words
			if valid
				words = title.split(" ")

				# See if any of the words match a stop word
				# if so, remove them with array subtraction
				words = words - stop_words

				# Iterate through words in the current line
				(0..(words.length - 2)).each do |i|

					# Three possible cases:
					# One: current word has not been added yet
					# Two: the word after current word has not been added yet
					# Three: both words have been added, so increment the count

					if $bigrams[words[i]].nil?
						$bigrams[words[i]] = Hash.new
						$bigrams[words[i]][words[i+1]] = 1
					elsif $bigrams[words[i]][words[i+1]].nil?
						$bigrams[words[i]][words[i+1]] = 1
					else
						$bigrams[words[i]][words[i+1]] += 1
					end
				end
			end

		end	# End of line iteration

		# Check 2 testing
		#p "Length of Bigram: #{$bigrams.size}"
		#p "#{$bigrams["happy"]}"
		#p mcw("happy")
		#p mcw("sad")
		#p mcw("love")

		puts "Finished. Bigram model built.\n"

		# Print debugging variables
		# puts "Valid lines: #{$num_lines}"
		# puts "Total lines: #{$total_lines}"

# Error catching if line processing fails
	rescue
		# use 'raise' if it is unclear where error is happening (shows call stack)
		# raise

		# print error message and exit
		STDERR.puts "Could not open file"
		exit 4
	end	# end rescue
end # end process_file

# Helper function to turn the entire file string into an array of lines
def split_string(str)
	str.split("\n")
end

# function for finding most common word to follow a given word
def mcw(word)

	# Make sure the word is in the bigram data structure
	if not $bigrams[word].nil?
		next_word = $bigrams[word].keys		# get all of the words that follow 'word'
		max = 0
		max_key = nil

		# Iteratively find the maximum count for all words following 'word'
		next_word.each do |key|
			if $bigrams[word][key] > max
					max = $bigrams[word][key]
					max_key = key
			end	# end if
		end # end maximum iteration loop

		return max_key # Return key associated with the largest count

	end # end if
	return nil	# return nil if the word is not in the data structure
end # end mcw

# generate a word to follow the arguement "word"
# This process should be semi-random and should terminate before 20 words
def get_next_word(word, count)

	# Check if random number from 0 to 99 is less than 400/count
	# 400/count helps create titles between 4 and 9 words long
	# shorter and longer titles are still possible, but less likely
	if rand(100) < 400/count

		# Ensure the word exists in the bigram
		if not $bigrams[word].nil?

			# Get an array of all words following 'word'
			words = $bigrams[word].keys
			return words[rand(words.length)]	# Return a random element from the words array

		end # end if (nil check)
	end # end if (random check)

	return nil	# return nil if the random number is not in the correct range or word is not in bigram
end # end get_next_word

# Function that iteratively creates song titles
# This function can use the mcw or get_next_word functions to create titles
def create_title(word)

	# Start with given word and a count of 1
	word_count = 1
	title = "#{word}"

	# next_word can be generated from either of the two functions (mcw, get_next_word)
	# next_word = mcw(word)
	next_word = get_next_word(word, word_count)

	# Iterate until the next_word function returns nil
	while not next_word.nil?
		# Add the next_word to the title
		title += " #{next_word}"

		# Find another word using last word as the new input
		#next_word = mcw(next_word)
		next_word = get_next_word(next_word, word_count)
		word_count += 1
	end # end while loop

	return title # Return the created title, minimum will be the word passsed in
end # end create_title

# function required for self check 1
# Performs same processing as the first part of process_file
# This function is called once per line from self check 1
def cleanup_title(line)
begin
		line += "\n"	# Add the endline character back after spliting on it

		# Force the encoding to utf-8 to avoid issues with non english characters
		line.force_encoding 'utf-8'

		# do something for each line
		# use regexp to remove junk before the title
		before_title_re = /.*>/
		line.sub!(before_title_re, "")
		title = line

		# us regexp to remove junk after main song title
		after_title_re = /(\(|\[|\{|\\|\/|_|-|:|"|`|\+|=|\*|feat\.).*/
		title.sub!(after_title_re, "")

		# Remove punctuation from titles, perform global replace (gsub!)
		# Remove ? ¿ ! ¡ . ; & @ % # |
		punc_re = /(\?|¿|!|¡|\.|;|&|@|%|#|\|)/
		title.gsub!(punc_re, "")

		# Remove non english characters by finding all lines with only desired characters
		english_re = /^(\w|'|\s)+\n$/
		if line =~ english_re
			valid = true
		else
			# If the line contains non english characters, set it to nil and change
			# the valid flag to false
			valid = false
			line = nil
		end

		# Only continue processing if valid is true

		title.downcase! if valid	# Set to lowercase if the line is valid

	  return title	# return the processed title (can be nil)

	rescue
		STDERR.puts "Could not open file"
		exit 4
	end # end rescue
end # end cleanup_title

# Executes the program
def main_loop()
	puts "CSCI 305 Ruby Lab submitted by #{$name}"

	if ARGV.length < 1
		puts "You must specify the file name as the argument."
		exit 4
	end

	# process the file
	process_file(ARGV[0])

	# test mcw
	# p "Unique words following computer: #{$bigrams["computer"].count}"
	# p "Most common word to follow computer: #{mcw("computer")}"
	# p "Number of times it follows computer: #{$bigrams["computer"][mcw("computer")]}"

	# test song creation
	puts create_title("amore")
	puts create_title("love")
	puts create_title("little")
	puts create_title("happy")

	# Get user input
	print "Enter a word>> "
	input = $stdin.gets.chomp.downcase	# make input case insensitive

	# Continue getting user input until the user enters 'q'
	while input != 'q'
		puts create_title(input)
		print "Enter a word>> "
	  input = $stdin.gets.chomp.downcase
	end	# end input loop

end	# end main_loop

main_loop()
