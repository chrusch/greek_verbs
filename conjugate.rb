#!/usr/bin/ruby -I .
require "principal_part_list"
require "finite_verb_conjugator"
require "participle_conjugator"

def data_from_line_oriented_file(filename) 
  ret_data = []
  File.open(filename, 'r') do |f|
    while (line = f.gets) do
      line.chomp!
      next if line =~ /^\s*\#/
      next if line =~ /^\s*$/
      fields = line.split(/\s+/)
      ret_data << (yield *fields)
    end
  end
  return ret_data
end

# read file with data about conjugating finite verbs
finite_verb_conjugators =
  data_from_line_oriented_file('finite_endings.dta') do |*fields|
    FiniteVerbConjugator.new(*fields)
  end

# read file with data about conjugating participles
participle_conjugators =
  data_from_line_oriented_file('participle_endings.dta') do |*fields|
    ParticipleConjugator.new(*fields)
  end

# read file with data about specific verbs
principal_part_lists =
  data_from_line_oriented_file('principal_parts.dta') do |*fields|
    PrincipalPartList.new(*fields)
  end

# do all the conjugations
verb_forms = []
principal_part_lists.each do |ppl|
  finite_verb_conjugators.each do  |fvc|
    verb_forms += fvc.conjugate(ppl)
  end
  participle_conjugators.each do  |pc|
    verb_forms += pc.conjugate(ppl)
  end
end

#puts verb_forms.inspect

# convert all conjugations to a better datastructure for our particular application
reverse_lookup = Hash.new { |h,k| h[k] = [] }
already_added = Hash.new
verb_forms.each do |one_form|
  code, form, base_form, english_conjugation = one_form

  # don't add the same combination of code, form, and base form
  # twice.  This can happen for instance with verbs like ευρον/ηυρον.
  next if already_added["#{code}+#{form}+#{base_form}"]
  reverse_lookup[form] << [code, base_form, english_conjugation]
  already_added["#{code}+#{form}+#{base_form}"] = true
end

puts 'var data = ['
reverse_lookup.each do |form, code_and_base_form|
  #next unless code_and_base_form.length > 1
  puts "['#{form}', #{code_and_base_form}],"
end
puts '];';

