stop_words = %w{a an the of fox}
sentence = %w{the quick brown fox jumped over the lazy dog an a bear came too}

print "\n#{stop_words}\n"
print "#{sentence}\n"
print "#{sentence - stop_words}\n"
