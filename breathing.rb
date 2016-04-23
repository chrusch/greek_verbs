class Breathing
  @@rough_forms         = 'ῥἁἑὁὑἡἱὡᾁᾑᾡἅἕὅὕἥἵᾅᾕᾥὥἃἓὃὓἣἳὣᾃᾓᾣἇὗἧἷὧᾇᾗᾧ'
  @@smooth_forms        = 'ῤἀἐὀὐἠἰὠᾀᾐᾠἄἔὄὔἤἴᾄᾔᾤὤἂἒὂὒἢἲὢᾂᾒᾢἆὖἦἶὦᾆᾖᾦ'
  @@non_aspirated_forms = 'ραεουηιωᾳῃῳάέόύήίᾴῄῴώὰὲὸὺὴὶὼᾲῂῲᾶῦῆῖῶᾷῇῷ'

  def self.is_rough?(word)
    (word =~ /[#{@@rough_forms}]/) || (word =~ /^ρ/) ?
      true :
      false
  end

  # Remove rough and smooth breathing marks to simplify the
  # the processing of verb forms.
  def self.remove_breathing(form)
    form.tr(@@rough_forms + @@smooth_forms,
            @@non_aspirated_forms + @@non_aspirated_forms)
  end

  # Add a rough breathing to the final verb form.
  def self.rough(form)
    case form
    when /^(?:[αεου][ιὶίῖ]|[αεοη][υύὺῦ])/
      asp = form[1].tr('ιίὶῖυύὺῦ', 'ἱἵἳἷὑὕὓὗ')
      form.sub(/^(.)./, '\1' + asp)
    when /^[#{@@non_aspirated_forms}]/
      asp = form[0].
        tr(@@non_aspirated_forms, @@rough_forms)
      form.sub(/./, asp)
    else
      form
    end
  end

  # Add a smooth breathing to the final verb form.
  def self.smooth(form)
    case form
    when /^(?:[αεου][ιὶίῖ]|[αεοη][υύὺῦ])/
      asp = form[1].tr('ιίὶῖυύὺῦ', 'ἰἴἲἶὐὔὒὖ')
      form.sub(/^(.)./, '\1' + asp)
    when /^[#{@@non_aspirated_forms}]/
      asp = form[0].
        tr(@@non_aspirated_forms, @@smooth_forms)
      form.sub(/./, asp)
    else
      form
    end
  end
end
