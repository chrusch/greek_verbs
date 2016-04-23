require "breathing"
require "augmenter"

# Encapsulate all the information we need about a principal part
# In particular
# * the augmented and unaugmented stems
# * the principal part itself
# * the principal part number
# * whether the principal part has a rough breathing
# * whether the princiapl part is deponent
# * in the case of pp #3, whether we have a first or second aorist
class PrincipalPart
  # A principle part can be expressed as a single verm form, e.g. αγω,
  # but there are ways to add extra information as needed:
  #
  # Note that future contracts are written out in the same way that present
  # contracts are.
  #
  # To show an irregular augmented (or unaugmented in the case of pp 3 and 6)
  # *stem*, i.e. what is after the "-" has no ending
  #
  # ὁραω-ἑωρα
  #
  # To show the stem explicitly:
  #
  # πεπεμμαι#πεπεμπ
  #
  # These various operations can be combined:
  #
  # a#b-c
  #
  # This is parsed like this:
  #
  # (a#b)-(c)
  #
  # There is no need to indicate smooth breathings on the principal part, but
  # explicit rough breathings are required
  #
  @@augmenter = nil

  def initialize(pp_string, principal_part_num, prefix_preposition)
    #warn "HERE A #{pp_string}"
    @principal_part_num = principal_part_num
    # 3rd or 6th principal parts are augmented
    is_augmented_pp = @principal_part_num == 3 || @principal_part_num == 6
    # the second pp never needs to be augmented, so don't try
    has_both_forms = @principal_part_num != 2

    #we need to derive certain information for each principal part
    #  * augmented stem
    #  * unaugmented stem
    #  * whether it has a rough breathing
    @first_form = nil
    first_form_stem = nil
    second_form_stem = nil

    # get first form and optional second form stem
    if pp_string =~ /-/
      @first_form, second_form_stem = pp_string.split(/\-/)
    else
      @first_form = pp_string
    end

    # Is the stem provided explictly?
    # If so, we don't have to back-form it.
    if @first_form =~ /\#/
      @first_form, first_form_stem = @first_form.split(/\#/)
    end

    # Is the breathing on the word rough?
    # For simplicity of processing, remove the breathing.
    @rough = Breathing.is_rough?(@first_form)
    @first_form = Breathing.remove_breathing(@first_form)

    # Get the first form stem if necessary.
    if first_form_stem.nil?
      raise pp_string unless @first_form
      first_form_stem = basic_stem()
    end

    # Get the second form stem if necessary.
    #warn "HERE Z #{is_augmented_pp}"
    if second_form_stem.nil? && has_both_forms
      @@augmenter ||= Augmenter.new
      if is_augmented_pp
        second_form_stem = @@augmenter.remove_augment(first_form_stem, prefix_preposition)
      else
        second_form_stem = @@augmenter.add_augment(first_form_stem, prefix_preposition)
      end
    end
    augmented_form = nil
    unaugmented_form = nil
    if is_augmented_pp
      augmented_form = @first_form
      @augmented_stem = first_form_stem
      @unaugmented_stem = second_form_stem
    else
      unaugmented_form = @first_form
      @unaugmented_stem = first_form_stem
      @augmented_stem = second_form_stem
    end

    #warn [@unaugmented_stem, @augmented_stem]

    @deponent = false
    if @principal_part_num == 2 # check if the future is deponent
      if unaugmented_form =~ /ο[υ]μαι$/
        @deponent = true
      end
    end

    @second_aorist = false
    @first_aorist = false
    if @principal_part_num == 3 # check if we have a first or second aorist
      if augmented_form =~ /ον$/
        @second_aorist = true
      else
        @first_aorist = true
      end
    end
  end

  def principal_form
    @first_form
  end

  def part_num
    @principal_part_num
  end

  def augmented_stem
    @augmented_stem
  end

  def unaugmented_stem
    @unaugmented_stem
  end

  def is_rough?
    raise @rough.class.to_s unless @rough == false || @rough == true
    @rough
  end

  def is_deponent?
    @deponent
  end

  def is_first_aorist?
    @first_aorist
  end

  def is_second_aorist?
    @second_aorist
  end

  private

  # Remove the ending from a verb form to back-form
  # the basic stem.
  def basic_stem
    # undo some euphonic changes so that we can recover
    # the basic stem
    form = @first_form.sub(/(?:μμαι)$/,'πμαι') # palatal
    form = form.sub(/(?:σμαι)$/,'τμαι') # dental
    form = form.sub(/(?:ουμαι)$/,'εομαι') # future contracted deponents

    # now remove the ending
    form.sub(/(?:ω|ον|α|ομαι|μαι|ην)$/,'')
  end

end
