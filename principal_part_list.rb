require "principal_part"

# Encapsulate all information about the principal parts of one verb
class PrincipalPartList
  # Takes input like, for example:
  #        die dies dying died died x αποθνῃσκω αποθανουμαι απεθανον X τεθνηκα - -
  # The lowercase x indicates that the PPs that follow
  # have a prefix preposition
  # The uppercase x indicates that the PPs that follow
  # do not have a prefix preposition
  #
  # The two hyphens at the end indicate that there are no fifth and
  # sixth principal parts.
  attr_reader :english_principal_parts
  def initialize(*raw_principal_parts)
    principal_part_num = 0
    prefix_preposition = false
    @principal_part_list = []
    @english_principal_parts = raw_principal_parts.shift(5)
    raw_principal_parts.each do |pp|
      # Does this verb have a prefixed preposition?
      # e.g. επι-πληττω 
      # Some verbs have a prefix preposition in some
      # forms but not in others 
      if pp == 'x'
        prefix_preposition = true
        next
      elsif pp == 'X'
        prefix_preposition = false
        next
      end
      principal_part_num += 1;
      next if pp == '-'

      # some verbs have more than one 3rd principal part (for example)
      pp_alternatives = pp.split(/\+/)
      pp_alternatives.each do |pp_alternative|
        @principal_part_list <<
          PrincipalPart.new(pp_alternative, principal_part_num, prefix_preposition)
      end
    end
  end

  def first_principal_part
    pp = @principal_part_list[0]
    return nil unless pp.part_num == 1
    return pp.principal_form
  end

  def each(&block)
    @principal_part_list.each(&block)
  end

  def aspirated_accented_first_pp
    @aspirated_accented_first_pp
  end

  def aspirated_accented_first_pp=(form)
    @aspirated_accented_first_pp = form
  end
end
