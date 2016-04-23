class Accenter
  # Implement one possible accenting policy.
  def self.add_accent_on_first_syl_of_ending(stem, ending, new_form)
    parts = get_parts_of_form(new_form)
    map_of_parts = get_map_of_parts(parts)
    #puts map_of_parts
    #puts parts.inspect
    ending_syl_cnt = count_syllables(ending)
    non_contract_accent(ending_syl_cnt, parts, map_of_parts)
    accented_form  = parts.join('')
    # remove capital letters which just exist to distinguish between long and
    # short
    # syllables
    accented_form.tr!('ΑΙΥ', 'αιυ')
    #puts accented_form
    return accented_form
  end

  # Most common accenting policy.
  def self.add_recessive_accent(stem, ending, new_form)
    #puts "HERE B #{stem} #{ending} #{new_form}"
    parts = get_parts_of_form(new_form)
    map_of_parts = get_map_of_parts(parts)
    #puts map_of_parts
    #puts parts.inspect
    syllable_cnt = map_of_parts['syllable_cnt']

    ending_syl_cnt = count_syllables(ending)
    if count_syllables(stem) + ending_syl_cnt == syllable_cnt
      # non-contract verb
      non_contract_accent(syllable_cnt, parts, map_of_parts)
    else
      contract_accent(ending_syl_cnt, parts, map_of_parts, ending)
    end
    accented_form  = parts.join('')
    # remove capital letters which just exist to distinguish between long and
    # short
    # syllables
    accented_form.tr!('ΑΙΥ', 'αιυ')
    #puts accented_form
    return accented_form
  end

  # A common accenting policy.
  def self.add_circumflex_on_ultima(form)
    parts = get_parts_of_form(form)
    map_of_parts = get_map_of_parts(parts)
    accented_part = map_of_parts[1]
    parts[accented_part] = circumflex(parts[accented_part])
    accented_form  = parts.join('')
    # remove capital letters which just exist to distinguish between long and
    # short
    # syllables
    accented_form.tr!('ΑΙΥ', 'αιυ')
    #puts accented_form
    return accented_form
  end

  # Another possible accenting policy.
  def self.add_accent_on_final_syl_of_stem(stem, ending, new_form)
    parts = get_parts_of_form(new_form)
    map_of_parts = get_map_of_parts(parts)
    #puts map_of_parts
    #puts parts.inspect
    ending_syl_cnt = count_syllables(ending)
    syllable_cnt = map_of_parts['syllable_cnt']

    if count_syllables(stem) + ending_syl_cnt == syllable_cnt
      # non-contract verb
      non_contract_accent(ending_syl_cnt + 1, parts, map_of_parts)

      #puts accented_part
    else # contract verb
      contract_accent(ending_syl_cnt, parts, map_of_parts, ending)

    end

    accented_form  = parts.join('')
    # remove capital letters which just exist to distinguish between long and
    # short
    # syllables
    accented_form.tr!('ΑΙΥ', 'αιυ')
    #puts accented_form
    return accented_form
  end

  private

  def self.non_contract_accent(part_to_try_to_accent, parts, map_of_parts)
    # For simplicity, we expect any verb with less than 3 syllables to have
    # exactly 2 (i.e. no one-syl verbs)
    syllable_cnt = map_of_parts['syllable_cnt']
    ultima = (parts[map_of_parts[1]..(parts.length - 1)]).join('')
    raise map_of_parts.inspect + parts.inspect if map_of_parts[2].nil?
    penult_vowel_or_dt = parts[map_of_parts[2]]
    part_to_try_to_accent = [part_to_try_to_accent, syllable_cnt, 3].min
    if part_to_try_to_accent == 1
        accented_part = map_of_parts[1]
        parts[accented_part] = acute(parts[accented_part])
    elsif part_to_try_to_accent == 2
      accented_part = map_of_parts[2]
      parts[accented_part] =
        if ! is_long_ultima?(ultima) and is_long?(penult_vowel_or_dt)
          # e.g. εῦρον
          circumflex(parts[accented_part])
        else
          # e.g. πέμπω or εύρου
          acute(parts[accented_part])
        end
    elsif part_to_try_to_accent == 3
      accented_idx = is_long_ultima?(ultima) ? 2 : 3
      accented_part = map_of_parts[accented_idx]
      parts[accented_part] = acute(parts[accented_part])
    else
      raise 'should not happen'
    end
  end

  # Split a verb form into its constituent parts (i.e. syllables)
  # so that we can accent it properly.
  def self.get_parts_of_form(form)
    parts = form.split(/(αι|αυ|ει|ευ|ηυ|οι|ου|υι|αΙ|εΙ|οΙ|ᾳ|ῃ|ῳ|[ΑΙΥηωαειου])/)
    parts.shift if parts[0] == ''
    return parts
  end

  # Deal with accents on contract verbs.
  def self.contract_accent(contracted_syllable, parts, map_of_parts, ending)
    # if ultima is long + contracted, and original ultima is long (for an  ultima)
    # circumflex on ultima
    # if ultima is long + contracted, and original ultima is short (for an
    # ultima)
    # acute on antepenult
    # if ultima is long + contracted, circumflex on ultima
    # if ultima is long but not contracted, acute on penult

    # if ultima is short + penult is contracted, circumflex on penult
    # if ultima is short + penult not contracted, acute on antepenult

    # if the ending is n syllables long, the contraction occurs on the
    # nth syllable from the end

    ultima = (parts[map_of_parts[1]..(parts.length - 1)]).join('')
    if is_long_ultima?(ultima)
      if contracted_syllable == 1 # ultima is contracted syllable
        if is_long_ultima?(ending)  # e.g. δηλῶ
          accented_part = map_of_parts[1]
          parts[accented_part] = circumflex(parts[accented_part])
        else # e.g. εφίλεις
          accented_part = map_of_parts[2]
          parts[accented_part] = acute(parts[accented_part])
        end
      else # e.g. φιλούντων
        accented_part = map_of_parts[2]
        parts[accented_part] = acute(parts[accented_part])
      end
    else  # short ultima
      if contracted_syllable == 2 # contraction on the penult e.g. φιλοῦσιν
        accented_part = map_of_parts[2]
        parts[accented_part] = circumflex(parts[accented_part])
      else # e.g. φιλούμεθα
        accented_part = map_of_parts[3]
        raise parts.inspect if accented_part.nil?
        parts[accented_part] = acute(parts[accented_part])
      end
    end
  end

  # Create a handy data structure with the parts (i.e. syllables)
  # of a word.
  def self.get_map_of_parts(parts)
    map_of_parts = Hash.new
    c = 0
    n = parts.length
    parts.reverse.each do |part|
      n -= 1
      if is_vowel_or_dt?(part)
        c += 1
        map_of_parts[c] = n
      end
    end
    map_of_parts['syllable_cnt']  = c
    return map_of_parts
  end

  def self.count_syllables(form)
    simplified = form.
      gsub(/(?:αι|αΙ|αυ|ει|εΙ|οΙ|ευ|ηυ|οι|ου|υι|ᾳ|ῃ|ῳ|[ΑΙΥηω])/, 'L').
      gsub(/[αειου]/, 'S').gsub(/[^SL]/,'')
    #puts simplified
    return simplified.length
  end

  # Is the vowel or diphthon long?
  def self.is_long?(v_or_dt)
    v_or_dt =~ /(?:αι|αΙ|αυ|ει|εΙ|οΙ|ευ|ηυ|οι|ου|υι|ᾳ|ῃ|ῳ|[ΑΙΥηω])/
  end

  # oi an ai are considered long in the ultima if they are followed by a
  # consonant
  def self.is_long_ultima?(ultima)
    ultima =~ /(?:αι.|αυ|ει|εΙ|οΙ|αΙ|ευ|ηυ|οι.|ου|υι|ᾳ|ῃ|ῳ|[ΑΙΥηω])/
  end

  # Is the given form a vowel or diphthong?
  def self.is_vowel_or_dt?(form)
    form =~ /[ΑΙΥηωαειουᾳῃῳ]/
  end

  # Add an acute accent to the given vowel of diphthong.
  def self.acute(v_or_dt)
    accented_vowel = v_or_dt[-1].tr('ΑΙΥηωαειουᾳῃῳ', 'άίύήώάέίόύᾴῄῴ')
    v_or_dt.sub(/.$/, accented_vowel)
  end

  # Add a circumflex accent to the given vowel of diphthong.
  def self.circumflex(v_or_dt)
    accented_vowel = v_or_dt[-1].tr('ΑΙΥηωαιυᾳῃῳ', 'ᾶῖῦῆῶᾶῖῦᾷῇῷ')
    v_or_dt.sub(/.$/, accented_vowel)
  end
end
