require 'set'
require 'digest/sha1'

all_files = Hash.new {|h,k| h[k] = []}
shinglers = []
by_file = Hash.new {|h,k| h[k] = 0}

def minW(a, s)
    return a.sort_by{|x| x[1]}[0..s-1]
end

def make_sketch(text, all_files, file, by_file, persist=nil)
    words = text.split(/\s+/)

	shingles = Set.new
	
	while words.size > 4 do
	    shingle = words[0..3]
        sha1 = Digest::SHA1.hexdigest(shingle.join(''))
	    shingles.add([shingle, sha1])
        unless persist.nil? then all_files[sha1].push file; end
        by_file[file] = by_file[file] + 1
	    junk = words.shift
	end

    u = shingles
    pi = u.sort_by{rand}
    fA = minW(pi, 25) # sketch
    fB = 0

    return u, fA
end

store, test = [], []
seen = nil
ARGV.each { |i|
    if i == '--' then seen = 1; next; end
    (seen.nil? ? store : test).push i
}
p store
p test

store.each { |file|
    puts "sketching #{file}"
    text = File.new(file).readlines.join("\n").downcase
    shingles, fA = make_sketch(text, all_files, file, by_file, 'yes')
    shinglers.push [shingles, fA, file]
}

test.each { |file|
    puts "testing #{file}"
    text = File.new(file).readlines.join("\n").downcase
    shingles, fA = make_sketch(text, all_files, file, by_file)
    common = Hash.new { |h,k| h[k] = 0}
    all = 0

# shingles in our test data
    shingles.each {|sh, hsh|
# if we've seen it before, count it as common
        unless all_files[hsh].nil? then
            all_files[hsh].each { |f|
                common[f] = common[f] + 1
            }
        end
    }
    common.each {|k,v|
        puts "k=#{k} v=#{common[k]} bf=#{by_file[k]} pc=#{100*common[k]/by_file[k]}%"
    }
}

__END__
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
