#!/usr/bin/env ruby
ary1 = []
ary2 = []
ARGF.each do |l|
  op, opt = l.chomp.split("\t")
  if opt =~ /s/ # single
    ary2.push(op)
  else
    ary1.push(op)
  end
end
puts ary1.sort.map {|i| %Q("#{i}") }.join(' ')
puts ary2.sort.map {|i| %Q("#{i}") }.join(' ') unless ary2.empty?
