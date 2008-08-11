require 'set'
require 'digest/sha1'

shinglers = []

def minW(a, s)
    return a.sort_by{|x| x[1]}[0..s-1]
end

ARGV.each { |file|
    text = File.new(file).readlines.join("\n").downcase
    words = text.split(/\s+/)

	shingles = Set.new
	
	while words.size > 4 do
	    shingle = words[0..3]
        sha1 = Digest::SHA1.hexdigest(shingle.join(''))
	    shingles.add([shingle, sha1])
	    junk = words.shift
	end

    u = shingles
    pi = u.sort_by{rand}
    fA = minW(pi, 25)
    fB = 0

    shinglers.push [shingles, fA, file]
}

first = shinglers.shift

shinglers.each { |s|
    sA = first[1]
    sB = s[1]

	intersect = sA & sB
	union = sA | sB
	
	rAB = intersect.size.to_f / union.size.to_f
	cAB = intersect.size.to_f / first.size.to_f
	
    ub_t = (minW(sA | sB, 25) & sA & sB).size.to_f
    ub_b = (minW(sA | sB, 25)).size.to_f
    ub = ub_t / ub_b

	puts "rAB = #{rAB}, cAB = #{cAB}, ub = #{ub}"

    first = s
}
