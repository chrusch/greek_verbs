require "accenter"
require "contracter"
class Inflector
  # Combine the stem and the ending and add an accent according to the
  # the given accenting policy.
  def add_ending(stem, ending, accent_policy)
    @@contracter ||= Contracter.new()
    new_form = @@contracter.new_form(stem, ending)

    return nil if new_form.nil?

    # accent
    if accent_policy == 'r'
      new_form = Accenter.add_recessive_accent(stem, ending, new_form)
    elsif accent_policy == 'e1'
      new_form = Accenter.add_accent_on_first_syl_of_ending(stem, ending, new_form)
    elsif accent_policy == 'sf'
      new_form = Accenter.add_accent_on_final_syl_of_stem(stem, ending, new_form)
    elsif accent_policy == 'cu'
      new_form = Accenter.add_circumflex_on_ultima(new_form)
    end

    return new_form
  end
end
