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
$num_lines = 0
$total_lines = 0

# function to process each line of a file and extract the song titles
def process_file(file_name)
	puts "Processing File.... "
	stop_words = %w{a an and by for from in of on or out the to with}

	begin
		#IO.foreach(file_name) do |line|
		line_arr = Array.new
		file_size = File.new(file_name).size
		puts "#{file_name} is #{file_size} bytes long"
		File.open(file_name) do |f|
			line_arr = split_string(f.read(file_size)) until f.eof?
		end
		line_arr.each do |line|
			line += "\n"
			# do something for each line
			# use regexp to remove junk before the title
			line.force_encoding 'utf-8'
			before_title_re = /.*>/
			line.sub!(before_title_re, "")
			title = line

			# us regexp to remove junk after main song title
			after_title_re = /(\(|\[|\{|\\|\/|_|-|:|"|`|\+|=|\*|feat\.).*/
			title.sub!(after_title_re, "")
			#match = title.scan(after_title_re).to_s

			# blank matches are clearing entire line, so check that something was matched
			#if match != "[]"
			#	title = title.sub!(after_title_re, "")
			#end

			# Remove punctuation from titles, perform global replace (gsub!)
			# Remove ? ¿ ! ¡ . ; & @ % # |
			punc_re = /(\?|¿|!|¡|\.|;|&|@|%|#|\|)/
			title.gsub!(punc_re, "")

			# Remove non english characters

			english_re = /^(\w|'|\s)+\n$/
			if line =~ english_re
				valid = true
			else
				valid = false
				line = nil
			end


			# set to lowercase
			title.downcase! if valid
			$num_lines += 1 if valid
			$total_lines += 1

			# Create bi-gram count from valid words
			# begin by spliting into individual words
			if valid
				words = title.split(" ")

				# See if any of the words match a stop word
				# if so, remove them with array subtraction
				words = words - stop_words

				(0..(words.length - 2)).each do |i|
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


			#puts title if valid
		end

		# Check 2 testing
		#p "Length of Bigram: #{$bigrams.size}"
		#p "#{$bigrams["happy"]}"
		#p mcw("happy")
		#p mcw("sad")
		#p mcw("love")
		puts "Finished. Bigram model built.\n"
		puts "Valid lines: #{$num_lines}"
		puts "Total lines: #{$total_lines}"

	rescue
		raise
		STDERR.puts "Could not open file"
		exit 4
	end
end

def split_string(str)
	str.split("\n")
end

# function for finding most common word to follow a given word
def mcw(word)
	if not $bigrams[word].nil?
		next_word = $bigrams[word].keys
		#p next_word
		max = 0
		max_key = nil
		next_word.each do |key|

			#p "#{key}: #{$bigrams[word][key]}"
			if $bigrams[word][key] > max
					max = $bigrams[word][key]
					max_key = key
			end
		end
		return max_key
	end
	return nil
end

# generate a word to follow the arguement "word"
# This process should be semi-random and should terminate before 20 words
def get_next_word(word)

end

def create_title(word)
	word_count = 1
	title = "#{word}"
	next_word = mcw(word)
	while not next_word.nil?
		title += " #{next_word}"
		next_word = mcw(next_word)
		word_count += 1
		break if word_count > 19
	end
	return title
end

# function required for self check 1
def cleanup_title(line)
begin
		# do something for each line
		# use regexp to remove junk before the title
		line.force_encoding 'utf-8'
		before_title_re = /.*>/
		line.sub!(before_title_re, "")
		title = line

		# us regexp to remove junk after main song title
		after_title_re = /(\(|\[|\{|\\|\/|_|-|:|"|`|\+|=|\*|feat\.).*/
		title.sub!(after_title_re, "")
		#match = title.scan(after_title_re).to_s

		# blank matches are clearing entire line, so check that something was matched
		#if match != "[]"
		#	title = title.sub!(after_title_re, "")
		#end

		# Remove punctuation from titles, perform global replace (gsub!)
		# Remove ? ¿ ! ¡ . ; & @ % # |
		punc_re = /(\?|¿|!|¡|\.|;|&|@|%|#|\|)/
		title.gsub!(punc_re, "")

		# Remove non english characters

		english_re = /^(\w|'|\s)+\n$/
		if line =~ english_re
			valid = true
		else
			valid = false
			line = nil
		end

		# set to lowercase
		title.downcase! if valid
	  return title
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
	input = $stdin.gets.chomp
	while input != 'q'
		puts create_title(input)
		print "Enter a word>> "
	  input = $stdin.gets.chomp
	end

end

main_loop()
