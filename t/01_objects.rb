require 'test/unit'
require 'digest_shingles'

$test_text = <<TEST_TEXT
this is some simple text for testing the shingles functionality
consisting of a few words without any punctuation merely because
said punctuation would be removed without regard for its safety
TEST_TEXT

# this text shouldn't match $test_text because the word order is different
$jumbled = ($test_text.split(' ').sort_by{|x|x.length}).join(' ')

class Test_Shingles < Test::Unit::TestCase
    def test_f1_f2_f3
        shinglers = Digest::Shingle::Archive.new()
        shinglers.add_file('t/f1')
        shinglers.add_file('t/f2')
        f1 = shinglers.match_file('t/f1')
        f2 = shinglers.match_file('t/f2')
        f3 = shinglers.match_file('t/f3')
        assert(f1, 'matches directly added f1')
        assert(f2, 'matches directly added f2')
        assert_equal(false, f3, 'no match for f3')
    end

    def test_text_lookup
        a = Digest::Shingle::Archive.new()
        # TODO find these files automatically
        a.add_file('t/f1')
        a.add_file('t/f3')

        t = File.new('t/f1').readlines.join("\n").downcase
        r = a.matches(t, 0.5)
        assert(r.size > 0, 'must have at least one match')
        names = r.map{|o|o.name}
        assert(r.find('t/f1'), 'found t/f1')
    end


    def test_files
        a = Digest::Shingle::Archive.new()
        # TODO find these files automatically
        a.add_file('t/f1')
        a.add_file('t/f2')
        a.add_file('t/f3')
        a.add_file('t/f4')

        t = File.new('t/f5').readlines.join("\n").downcase
        s = Digest::Shingle.new(t)
        r = a.matches(s, 0.75)
        p r
    end

    def test_f1_direct_f2
        a = Digest::Shingle::Archive.new()

        a.add_file('t/f1')
        f2 = a.match_file('t/f2')
        assert_equal(true, f2, 'f2 matches archived f1')
    end

    def test_f3_direct_f4
        a = Digest::Shingle::Archive.new()

        a.add_file('t/f3')
        r = a.match_file('t/f4')
        assert_equal(false, r, 'f4 no match for archived f3')
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
