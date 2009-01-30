=== Digest::Shingle ===

Implementation of shingles for approximately matching blocks of text

== Example ==

{{{
    a = Digest::Shingle::Archive.new()
    a.add('some text')
    a.add_file('somefilename.txt')
    ...
    s = Digest::Shingle.new('test text')
    if a.match(s) then # any of the shingles match?
        ...
    end
}}}

