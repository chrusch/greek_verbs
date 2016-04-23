class EnglishConjugator

  def self.conjugate(code, english_principal_parts)
    if code =~ /^vf/
      finite_verb(code.sub(/^vf/,''), english_principal_parts)
    elsif code =~ /^vp/
      participle(code.sub(/^vp/, ''), english_principal_parts)
    else
      raise "ERROR: Bad code: #{code}"
    end
  end

  private

  def self.pronoun(code)
    case code
    when /^2..v./ # second person imperative
      nil
    when /^3s.v./ 
      'let him'
    when /^4s.v./ 
      'let her'
    when /^5s.v./ 
      'let it'
    when /^3p.v./ 
      'let them'
    when /^1s.i./ # 1s person indicative
      'I'
    when /^2..i./
      'you'
    when /^3s.i./
      'he'
    when /^4s.i./
      'she'
    when /^5s.i./
      'it'
    when /^1p.i./
      'we'
    when /^3p.i./
      'they'
    when /^1s.s./ # 1st person subjunctive
      'that I'
    when /^2..s./
      'that you'
    when /^3s.s./
      'that he'
    when /^4s.s./
      'that she'
    when /^5s.s./
      'that it'
    when /^1p.s./
      'that we'
    when /^3p.s./
      'that they'
    when /^1s.o./ # 1st person optative
      'may I'
    when /^2..o./
      'may you'
    when /^3s.o./
      'may he'
    when /^4s.o./
      'may she'
    when /^5s.o./
      'may it'
    when /^1p.o./
      'may we'
    when /^3p.o./
      'may they'
    else
      raise "ERROR #{code}"
    end
  end

  def self.middle_suffix(code)
    # active and passive have no middle suffix
    if code =~ /[ap]$/
      return nil
    end
    
    # the suffix may be determined by the pronoun
    if true
      case code
      when /^3s/
        'for himself'
      when /^4s/
        'for herself'
      when /^5s/
        'for itself'
      when /^1s/
        'for myself'
      when /^2/
        'for yourself'
      when /^1p/
        'for ourselves'
      when /^3p/
        'for themselves'
      else
        raise "ERROR #{code}"
      end
    end
  end

  def self.auxiliary(code)
    if code =~ /^....[am]$/
      active_auxiliary(code)
    elsif code =~ /^....p$/
      passive_auxiliary(code)
    else
      raise "ERROR #{code}"
    end
  end

  def self.active_auxiliary(code)
    case code
    when /1sPi.$/  # I AM writing
      'am'
    when /2[sp]Pi.$/  # you ARE writing
      'are'
    when /[345]sPi.$/  # he/she/it IS writing
      'is'
    when /[123]pPi.$/  # we/you/they ARE writing
      'are'
    when /(pi|ai|2i|pv|av|2v).$/  # I write -- no aux
      nil
    when /[1345]sii.$/  # I/he was going
      'was'
    when /ii.$/  # you/we/they were going
      'were'
    when /fi.$/ # you WILL see
      'will'
    when /[345]sri.$/ # he/she/it HAS gone
      'has'
    when /ri.$/ # I/you/we/they HAVE gone
      'have'
    when /li.$/ # you HAD gone
      'had'
    when /[pa2]s.$/ # that he MAY see
      'may'
    when /[pfa2]o.$/ # may he see - -no auxiliary
      nil
    else 
      raise "#{code}"
    end
  end

  def self.passive_auxiliary(code)
    case code
    when /[1345]siip$/  # I/he was being seen 
      'was being'
    when /iip$/  # you/we/they were being seen
      'were being'
    when /[1345]saip$/  # I/he was seen 
      'was'
    when /aip$/  # you/we/they were seen
      'were'
    when /1spip$/  # I AM seen
      'am'
    when /[345]spip$/ # he/she/it IS seen
      'is' 
    when /pip$/ # we/they/you ARE seen
      'are'
    when /[345]srip$/ # he/she/it HAS BEEN seen
      'has been'
    when /rip$/ # I/you/we/they HAVE been seen
      'have been'
    when /lip$/ # you HAD BEEN seen
      'had been'
    when /fip$/ # you WILL BE seen
      'will be'
    when /[pa2]vp$/ # BE seen/ let him BE seen/ let them BE seen
      'be'
    when /[pa2f]op$/ # may he BE seen
      'be'
    when /[pa2]sp$/ # that he MAY BE seen
      'may be'
    else
      raise "ERROR #{code}"
    end
  end

  def self.principal_part(code, pps)
    pp_num =
      case code 
      when /^..Pi[am]/ # I am WRITING/ you are WRITING
        2
      when /^[345]spi[am]/ # he/she/it WRITES
        1
      when /^..[pf]i[am]/ # you WRITE/ you will WRITE
        0
      when /^..ii[am]/ # you were WRITING
        2
      when /^..[a2]i[am]/ # you WROTE
        3
      when /^..[rl]i./ # you have WRITTEN / you had been WRITTEN
        4
      when /^...v[am]/ # WRITE!
        0
      when /^..[fp2a]o[am]/ # may he SEE
        0
      when /^..[pa2]s[am]/ # that he may SEE
        0
      when /p$/ # passive verbs
        4
      else
        raise "no pp_num for code #{code}"
      end
    pps[pp_num]
  end

  def self.finite_verb(code, pps)
    r = more_detailed_codes(code).collect { |cd|
      #ward cd
      pr = pronoun(cd) # YOU write
      ph = auxiliary(cd) # you WERE written
      pp = principal_part(cd, pps) # you were WRITTEN
      ms = middle_suffix(cd) # you wrote FOR YOURSELF
      r = [pr, ph, pp, ms].compact.join(' ')
      #warn r
      r
    }.flatten
    #warn r.inspect
    r
  end

  #
  # some parsings have multiple english translations
  #
  # e.g. 3rd person sg can be translated as "he", "she", or "it"
  #
  # This method creates distinct code for each possible translation
  #
  # 4th pers. sg = "she ..."
  # 5th pers sg. = "it ..."
  #
  # "Pia" = "I am seeing" (cf "I see")
  def self.more_detailed_codes(code) 
    ret_cts = []
    if code =~ /^3s/
      he_code = code
      she_code = code.sub(/^3/, '4')
      it_code = code.sub(/^3/, '5')
      ret_cts = [ he_code, she_code, it_code ]
    else
      ret_cts = [ code ]
    end

    r = ret_cts.collect { |cd|
      if cd =~ /..pi[am]$/
        [cd, cd.sub(/pi(.)$/, 'Pi\1')]
      else
        [cd]
      end
    }.flatten

    #warn r.inspect
    r

  end

  
  # produce a product of arrays 
  # e.g. parts = [ ['he', 'she'], 'does not', ['hear', 'listen'] ]
  # produces:
  # [ 'he does not hear', 'she does not hear', 'he does not listen', 
  #   'she does not listen' ]
  def self.product_OBSOLETE(parts)
    prts = parts.dup
    ret =  [prts.shift].flatten
    prts.each do |part|
      ret = ret.product([part].flatten).collect { |ary| ary.join(' ') } 
    end
    #warn ret.inspect
    ret
  end

  def self.case_indicator(code)
    case code
    when /^n/
      nil
    when /^g/
      'of'
    when /^d/
      'to'
    when /^a/
      nil
    when /^v/
      nil
    end
  end

  def self.substantive_object(code)
    case code
    when /^.sm/
      'the man who'
    when /^.sf/
      'the woman who'
    when /^.pm/
      'the men who'
    when /^.pf/
      'the women who'
    when /^.sn/
      'the thing that'
    when /^.pn/
      'the things that'
    else
      raise code
    end
  end

  def self.participle_auxiliary(code)
    case code
    when /^.s.p.$/
      'is'
    when /^.p.p.$/
      'are'
    when /^.s.r[am]$/
      'has'
    when /^.p.r[am]$/
      'have'
    when /^.s.rp$/
      'has been'
    when /^.p.rp$/
      'have been'
    when /^...f[am]$/
      'will'
    when /^...fp$/
      'will be'
    when /^...[a2][am]$/
      nil
    when /^.s.[a2]p$/
      'was'
    when /^.p.[a2]p$/
      'were'
    else
      raise code
    end
  end

  # take takes taking took taken
  def self.participle_principal_part(code, pps)
    case code
    when /p[am]$/
      pps[2] # who is/are TAKING
    when /^...[pfa2]p$/
      pps[4] # who is being/are being/will be/was/were TAKEN
    when /^...f[am]$/
      pps[0] # who will TAKE
    when /^...[a2][am]$/
      pps[3] # who TOOK
    when /^...r.$/
      pps[4] # who has been/have been TAKEN
    else
      raise code
    end
  end

  def self.participle_middle_suffix(code)
    case code
    when /[ap]$/
      nil
    when /^.sm/
      'for himself'
    when /^.sf/
      'for herself'
    when /^.sn/
      'for itself'
    when /^.pm/
      'for themselves'
    when /^.pf/
      'for themselves'
    when /^.pn/
      'for themselves'
    else
      raise code
    end
  end

  def self.codes_from_participle_code(code)
    [code]
  end

  def self.participle(code, pps)
    codes = codes_from_participle_code(code)
    r = codes.collect { |cd|
      #warn cd
      ci = case_indicator(cd) # OF the woman who wrote for herself
      so = substantive_object(cd) # of THE WOMAN WHO wrote for herself
      ph = participle_auxiliary(cd) # of the woman who HAS written for herself
      pp = participle_principal_part(cd, pps) # of the woman who has WRITTEN for herself
      ms = participle_middle_suffix(cd) # of the woman who wrote FOR HERSELF
      r = [ci, so, ph, pp, ms].compact.join(' ')
      #warn r
      r
    }.flatten
    #warn r.inspect
    r
  end
end

