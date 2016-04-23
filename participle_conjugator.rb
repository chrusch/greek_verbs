require "inflector"
require "breathing"

# This class encapsulates all the information and logic
# needed to conjugate a given ParticipalPartList
# for a single gender, tense, and voice of participle
#
# Input data looks like this:
# 1 mpa sf ων οντος οντι οντα ων οντες οντων ουσι+ουσιν οντας οντες
# 1 means 1st principle part
# mpa means masculine present active
# r means recessive accent
# e1 means persistent accent on the first syllable of the ending
# sf means persistent accent on the final syllable of the stem
# cu means circumflex on the ultima
class ParticipleConjugator < Inflector
  def initialize(principal_part_num, gender_tense_voice, accent_policy, *endings)
    @gender, @tense, @voice = gender_tense_voice.split(//, 3)
    @voices = @voice.split(//) # to accommodate middle-passive endings
    @principal_part_num = principal_part_num.to_i
    @endings = []
    # in some cases, there is an automatic circumflex over the genitive
    # plural form of feminine participles
    automatic_circumflex_in_gp =
      %w(fap fpa ffa faa fra f2a).include?(gender_tense_voice)

    ['s', 'p'].each do |number| # singular or plural
      ['n', 'g', 'd', 'a', 'v'].each do |g_case| # nominative, genitive, etc.
        ending = endings.shift
        next if ending == '-'
        if automatic_circumflex_in_gp && number == 'p' && g_case == 'g'
          ap = 'cu'
        else
          ap = accent_policy
        end
        person_endings = ending.split(/\+/)
        person_endings.each do |person_ending|
          @endings << [number, g_case, person_ending, ap]
        end
      end
    end
  end

  # Generate all participle forms for a single verb
  # given the parsed principal parts.
  def conjugate(ppl)
    first_pp = ppl.first_principal_part
    full_conjugation = []
    ppl.each do |ppart|
      next unless @principal_part_num == ppart.part_num
      next if @tense == 'a' && ppart.is_second_aorist?  # skip 1st aorist when appropr.
      next if @tense == '2' && ppart.is_first_aorist?  # skip 1st aorist when appropr.
      @endings.each do |form_info|
        number, g_case, person_ending, ap = form_info
        form = add_ending(ppart.unaugmented_stem, person_ending, ap)
        form = ppart.is_rough? ? Breathing.rough(form) : Breathing.smooth(form)
        @voices.each do |voice|
          code = "vp#{g_case}#{number}#{@gender}#{@tense}#{voice}"
          english_conjugations = EnglishConjugator.conjugate(code, ppl.english_principal_parts)
          full_conjugation << [code, form, ppl.aspirated_accented_first_pp, english_conjugations]
        end
      end
    end
    return full_conjugation
  end

end
