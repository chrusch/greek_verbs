require "inflector"
require "breathing"
require "english_conjugator"

# This class encapsulates all the information and logic
# needed to conjugates a given ParticpalPartList
# for a single tense mood and voice
class FiniteVerbConjugator < Inflector
  def initialize(principal_part_num, tense_mood_voice, augment, *endings)
    @has_augment = augment == 'a'
    @principal_part_num = principal_part_num.to_i
    @tense, @mood, @voice = tense_mood_voice.split(//, 3)
    @endings = []
    ['s', 'p'].each do |number| #singular and plural
      [1, 2, 3].each do  |person| #1st, 2nd, 3rd
        ending = endings.shift
        next if ending == '-'
        person_endings = ending.split(/\+/)
        person_endings.each do |person_ending|
          @endings << [person, number, person_ending]
        end
      end
    end
  end

  def conjugate(ppl) # takes a principal_part_list
    first_pp = ppl.first_principal_part
    full_conjugation = []
    ppl.each do |ppart|
      next unless @principal_part_num == ppart.part_num
      # skip 1st aorist when appropriate
      next if @tense == 'a' &&  ppart.is_second_aorist?
      # skip 2nd aorist when appropriate
      next if @tense == '2' &&  ppart.is_first_aorist?
      # skip active forms of deponent verbs
      next if @voice == 'a' &&  ppart.is_deponent?
      @endings.each do |form_info|
        person, number, person_ending = form_info
        if @has_augment
          form = add_ending(ppart.augmented_stem, person_ending, 'r')
        else
          if @tense == 'a' and @mood == 's' and @voice == 'p'
            # aorist subjunctive passive is accented like an
            # epsilon contract
            form = add_ending(ppart.unaugmented_stem + 'ε', person_ending, 'r')
          else
            form = add_ending(ppart.unaugmented_stem, person_ending, 'r')
          end
        end
        next unless form
        form = ppart.is_rough? ?
          Breathing.rough(form) :
          Breathing.smooth(form)
        unless ppl.aspirated_accented_first_pp
          ppl.aspirated_accented_first_pp = form
        end
        # the voice may be middle/passive (mp)--treat these as two separate
        # forms
        @voice.split(//).each do |voice| 
          code = "vf#{person}#{number}#{@tense}#{@mood}#{voice}"
          raise self.inspect if code.length > 7
          english_conjugation = EnglishConjugator.conjugate(code, ppl.english_principal_parts)
          full_conjugation << [code, form, ppl.aspirated_accented_first_pp, english_conjugation]
        end
      end
    end
    return full_conjugation
  end
end
