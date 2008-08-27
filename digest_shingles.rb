require 'set'
require 'digest/sha1'

module Digest
class Shingle
    attr_accessor :sketch, :shingles, :original

	def minW(a, s)
	    return a.sort_by{|x| x[1]}[0..s-1]
	end
	
	def make_sketch(text)
	    words = text.split(/\s+/)
	
		shingles = Set.new
		
		while words.size > 4 do
		    shingle = words[0..3]
	        sha1 = Digest::SHA1.hexdigest(shingle.join(''))
		    shingles.add([shingle, sha1])
#by_file[file] = by_file[file] + 1
		    junk = words.shift
		end
	
	    u = shingles
	    pi = u.sort_by{rand}
	    fA = minW(pi, 25) # sketch
	    fB = 0
	
        return u, fA
	end
	
	def initialize(text)
        @original = text
        @shingles, @sketch = make_sketch(text)
	end

    class Archive
        attr_accessor :storage, :all_counts

        def initialize()
            @storage = []
            @stored_hashes = Hash.new {|h,k| h[k]=[]}
            @all_counts = {}
            @oid_to_object = {}
        end

        def add(text, *extra)
            s = Digest::Shingle.new(text)
            self.add_shingle(s, extra)
        end

        def add_shingle(shingle, *extra)
            @storage.push [shingle, extra]
            shingle.shingles.each { |sh, hsh|
                @stored_hashes[hsh].push shingle.object_id
            }
            @all_counts[shingle.object_id] = shingle.shingles.size
            @oid_to_object[shingle.object_id] = shingle
        end

        def match(shingle, target=0.75)
            results = []
            common = Hash.new { |h,k| h[k] = 0}
            shingle.shingles.each { |sh, hsh|
	            unless @stored_hashes[hsh].nil? then
	                @stored_hashes[hsh].each { |f|
	                    common[f] = common[f] + 1
	                }
	            end
            }
            @all_counts.each { |k, v|
                ratio = common[k].to_f/v.to_f
                if ratio > target then
                    results.push k
                end
            }
            return results
        end
    end
end
end
