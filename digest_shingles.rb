require 'set'
require 'digest/sha1'
require 'yaml'

module Digest
class Shingle
    attr_accessor :sketch, :shingles, :original, :name

	def text
		return @original
	end

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
		    junk = words.shift
		end
	
	    u = shingles
	    pi = u.sort_by{rand}
	    fA = minW(pi, 25) # sketch
	    fB = 0
	
        return u, fA
	end

	def match(something)
		if something.respond_to? :shingles then
			myshingle = something
		else
			myshingle = Digest::Shingle.new(something.to_s)
		end

		myhashes = {}
		self.shingles.each { |sh, hsh|
			myhashes[hsh] = 1
		}

            	common = 0

		# TODO make this work on both directions at the same time?
		myshingle.shingles.each { |sh, hsh|
	            unless myhashes[hsh].nil? then
		    	common = common + 1
	            end
	    	}
		puts "ratio = #{common.to_f/self.shingles.size}"
	end

	
	def initialize(text, extra=nil)
        @original = text
        @name = extra || Digest::SHA1.hexdigest(text)
        @shingles, @sketch = make_sketch(text)
	end

    class Archive
        attr_accessor :storage, :all_counts

        def initialize(persist=nil)
            @storage = []
            @stored_hashes = Hash.new {|h,k| h[k]=[]}
            @all_counts = {}
            @oid_to_object = {}
        end

        def dump()
            YAML.dump([@storage, @stored_hashes, @all_counts, @oid_to_object])
        end

        def add(text, extra=nil)
            s = Digest::Shingle.new(text, extra)
            self.add_shingle(s, extra)
	        return s
        end

        def add_file(filename, extra=filename)
            text = File.new(filename).readlines.join("\n").downcase
            return self.add(text, extra)
        end

        def match_file(filename)
            text = File.new(filename).readlines.join("\n").downcase
            s = Digest::Shingle.new(text)
            return self.match(s, 0.90)
        end

        def add_shingle(shingle, *extra)
            @storage.push [shingle, extra]
            shingle.shingles.each { |sh, hsh|
                @stored_hashes[hsh].push shingle.object_id
            }
            @all_counts[shingle.object_id] = shingle.shingles.size
            @oid_to_object[shingle.object_id] = shingle
        end

        def match(something, target=0.75)
		if something.respond_to? :shingles then
            myshingle = something
        else
            myshingle = Digest::Shingle.new(something.to_s)
        end

		found = self.matches(myshingle, target)
		if found.size > 0 then
			return true
		else
			return false
		end
	end

        def matches(something, target=0.75)
            if something.respond_to? :shingles then
                myshingle = something
            else
                myshingle = Digest::Shingle.new(something.to_s)
            end
            results = []
            common = Hash.new { |h,k| h[k] = 0}
            myshingle.shingles.each { |sh, hsh|
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
            return results.map {|i| @oid_to_object[i]}
        end
    end
end
end
