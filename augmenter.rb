# Class for augmenting and un-augmenting verb forms
class Augmenter
  @@raw_augments = %w(
    ηυ ηυ
    η η
    α η
    ε η
    ι ι
    υ υ
    ο ω
    αι ῃ
    ει ῃ
    αυ ηυ
    ευ ηυ
    οι ῳ
    ρ ερρ
    ερρ ερρ 
    ω ω
  )

  @@prefix_prepositions =  %w(επι επ απο απ ανα αν)

  def initialize
    @all_augments = Hash.new
    @reverse_augments = Hash.new
    augmentable_beginnings = []
    augmented_beginnings = []
    raw_augments = @@raw_augments.clone
    while raw_augments.length >=2 do
      augment = raw_augments.shift(2)
      vowel, lengthened_vowel = *augment
      @all_augments[vowel] = lengthened_vowel
      # this is not perfect because of a lack of one-to-one relation
      # between unaugmented and augmented forms
      @reverse_augments[lengthened_vowel] = vowel
      augmentable_beginnings << vowel
      augmented_beginnings << lengthened_vowel
    end
    @reverse_augments['ερρ'] = 'ῥ'

    # put diphthongs first to make it easier to search for them
    # at the beginning of words and parts of words
    @all_augmentable_beginnings =
      augmentable_beginnings.sort { |a,b| b.length <=> a.length || a <=> b }.uniq
    @all_augmented_beginnings =
      augmented_beginnings.sort { |a,b| b.length <=> a.length || a <=> b }.uniq

    # prefix prepositions like epi, apo, ana, pros
    @all_prefix_prepositions = Hash.new
    @reverse_prefix_prepositions = Hash.new
    pp = @@prefix_prepositions.clone
    while pp.length > 0
      prep = pp.shift(2)
      full_prep, shortened_prep = *prep
      @all_prefix_prepositions[full_prep] = shortened_prep
      @reverse_prefix_prepositions[shortened_prep] = full_prep
    end
  end

  # Add an augment to the beginning of the verb form
  # (or in the case of verbs with prefix prepositions, to
  # the beginning of the base form)
  def add_augment(form, prefix_preposition)
    # deal first with prefix preposition like απο in αποθνησκω
    prefix_prep = ''
    new_form = form.clone
    if prefix_preposition
      @@prefix_prepositions.each do |prep|
        #puts prep
        if new_form =~ /^#{prep}/
          new_form.sub!(/^#{prep}/,'')
          prefix_prep = @all_prefix_prepositions[prep] || prep
          raise form if prefix_prep.nil?
        end
      end
    end

    beginning_vowel =
      @all_augmentable_beginnings.detect { |vowel| new_form =~ /^#{vowel}/ }

    ret = 
    if @all_augments[beginning_vowel]
      prefix_prep +
        new_form.sub(/^#{beginning_vowel}/, @all_augments[beginning_vowel] )
    else
      prefix_prep + 'ε' + new_form
    end
    #warn ret
    ret
  end

  # Remove the augment from a verb form.  This is needed to
  # back-form the stem, i.e. to generate the unaugmented stem from
  # an augmented principal part (i.e. as 3 and 6)
  def remove_augment(old_form, prefix_preposition)
    # deal first with prefix preposition like απο in αποθνησκω
    #puts old_form
    form = old_form.clone
    prefix_preps = ['','']
    if prefix_preposition
      @all_prefix_prepositions.values.each do |prep| #something like επ απ αν προσ
        if form =~ /^#{prep}/
          form.sub!(/^#{prep}/,'')
          # reverse_prefix_prepositions maps απο to απ, etc.
          prefix_preps = [prep, @reverse_prefix_prepositions[prep]]
        end
      end
    end

    beginning_string =
      @all_augmented_beginnings.detect { |beginning| form =~ /^#{beginning}/ }
    new_form =
      if @reverse_augments[beginning_string]
        form.sub(/^#{beginning_string}/, @reverse_augments[beginning_string] )
      else
        form.sub(/^ε([^υ])/,'\1')
      end
    #puts new_form
    r  =
    if new_form =~ /^[αειουηωᾳῳῃ]/
       prefix_preps[0] + new_form
    else
       prefix_preps[1] + new_form
    end
    #puts r
    return r
  end
end
