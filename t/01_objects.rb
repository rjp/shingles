require 'test/unit'
require 'digest_shingles'

$test_text = <<TEST_TEXT
this is some simple text for testing the shingles functionality
consisting of a few words without any punctuation merely because
said punctuation would be removed without regard for its safety
TEST_TEXT

$jumbled = ($test_text.split(' ').sort_by{|x|x.length}).join(' ')

p $jumbled

class Test_Shingles < Test::Unit::TestCase
    def test_f1_f2
        shinglers = Digest::Shingle::Archive.new()
        shinglers.add_file('t/f1')
        shinglers.add_file('t/f2')
        f1 = shinglers.match_file('t/f1')
        f2 = shinglers.match_file('t/f2')
        f3 = shinglers.match_file('t/f3')
        assert(f1, 'matches f1')
        assert(f2, 'matches f2')
        assert_equal(false, f3, 'no match for f3')
    end

    def test_simplistic
        a = Digest::Shingle::Archive.new()

        s1 = a.add($test_text, 's1')
        s2 = a.add($test_text, 's2')
        assert_equal(true, a.match(s2), 's2 matches s1')
        assert_equal(true, a.match(s1), 's1 matches s2')

        s3 = Digest::Shingle.new('nothing goes here')
        assert_equal(false, a.match(s3), 's3 does not match')
    end

    def test_jumbled
        a = Digest::Shingle::Archive.new()

        s1 = a.add($test_text, 's1')
        s2 = Digest::Shingle.new($jumbled)

        assert_equal(false, a.match(s2), 'jumbled matches nothing')
    end

end

__END__
store, test = [], []
seen = nil
ARGV.each { |i|
    if i == '--' then seen = 1; next; end
    (seen.nil? ? store : test).push i
}
p store
p test

r = []
shinglers = Digest::Shingle::Archive.new()
store.each { |file|
    puts "sketching #{file}"
    text = File.new(file).readlines.join("\n").downcase
    s = shinglers.add(text, file)
    r.push s
}

test.each { |file|
    puts "testing #{file}"
    text = File.new(file).readlines.join("\n").downcase
    s = Digest::Shingle.new(text)
    p shinglers.match(s, 0.90)
	r.each { |q|
		q.match(s)
	}
}
