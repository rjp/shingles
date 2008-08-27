require 'digest_shingles'

store, test = [], []
seen = nil
ARGV.each { |i|
    if i == '--' then seen = 1; next; end
    (seen.nil? ? store : test).push i
}
p store
p test

shinglers = Digest::Shingle::Archive.new()
store.each { |file|
    puts "sketching #{file}"
    text = File.new(file).readlines.join("\n").downcase
    shinglers.add(text, file)
}

test.each { |file|
    puts "testing #{file}"
    text = File.new(file).readlines.join("\n").downcase
    s = Digest::Shingle.new(text)
    p shinglers.match(s, 0.90)
}

