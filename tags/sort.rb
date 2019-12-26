#!/usr/bin/env ruby
ary = []
ARGF.each do |l|
  ary.push(l.chomp)
end
puts ary.sort.map {|i| %Q("#{i}") }.join(' ')
