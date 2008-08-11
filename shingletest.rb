require 'set'

shinglers = []

ARGV.each { |file|
    text = File.new(file).readlines.join("\n").downcase
    words = text.split(/\s+/)

	shingles = Set.new
	
	while words.size > 4 do
	    shingle = words[0..3]
	    shingles.add(shingle)
	    junk = words.shift
	end
    
    shinglers.push shingles
}

first = shinglers.shift

shinglers.each { |s|
	intersect = first & s
	union = first | s
	
	rAB = intersect.size.to_f / union.size.to_f
	cAB = intersect.size.to_f / first.size.to_f
	
	puts "rAB = #{rAB}, cAB = #{cAB}"
    first = s
}
