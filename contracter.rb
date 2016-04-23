# All functionality related to creating verb contracts
class Contracter
  @@raw_contracts =
  %w(
  α ε Α
  α ει ᾳ
  α η Α
  α ῃ ᾳ
  α ο ω
  α οι ῳ
  α ου ω
  α ω ω
  ε ε εΙ
  ε ει εΙ
  ε η η
  ε ῃ ῃ
  ε ο ου
  ε οι οΙ
  ε ου ου
  ε ω ω
  ο ε ου
  ο ει οΙ
  ο η ω
  ο ῃ οΙ
  ο ο ου
  ο οι οΙ
  ο ου ου
  ο ω ω
  π μ μμ
  β μ μμ
  φ μ μμ
  κ μ γμ
  γ μ γμ
  χ μ γμ
  τ μ σμ
  δ μ σμ
  θ μ σμ
  ζ μ σμ
  ν μ σμ
  π σ ψ
  β σ ψ
  φ σ ψ
  κ σ ξ
  γ σ ξ
  χ σ ξ
  τ σ σ
  δ σ σ
  θ σ σ
  ζ σ σ
  φ σθ φθ
  π σθ φθ
  β σθ φθ
  κ σθ χθ
  γ σθ χθ
  χ σθ χθ
  ζ σθ σθ
  τ σθ σθ
  δ σθ σθ
  θ σθ σθ
  λ σθ λθ
  ρ σθ ρθ
  ν σθ νθ
  π τ πτ
  β τ πτ
  φ τ πτ
  κ τ κτ
  γ τ κτ
  χ τ κτ
  τ τ στ
  δ τ στ
  θ τ στ
  ζ τ στ
  β ν --BAD--
  γ ν --BAD--
  δ ν --BAD--
  ζ ν --BAD--
  θ ν --BAD--
  κ ν --BAD--
  λ ν --BAD--
  μ ν --BAD--
  ν ν --BAD--
  ξ ν --BAD--
  π ν --BAD--
  ρ ν --BAD--
  ς ν --BAD--
  σ ν --BAD--
  τ ν --BAD--
  φ ν --BAD--
  χ ν --BAD--
  ψ ν --BAD--
  )
  # Take raw contract data and generate
  # appropriate data structures.
  def initialize()
    @all_contracts = Hash.new { |h,k| h[k] = Hash.new }
    @all_ending_sequences = []
    @all_stem_sequences = []
    raw_contracts = @@raw_contracts.clone
    while raw_contracts.length >= 3 do
      euphonic_transformation = raw_contracts.shift(3)
      stem_seq, ending_seq, euphonic_change = *euphonic_transformation
      @all_contracts[stem_seq][ending_seq] = euphonic_change
      #puts ending_seq
      @all_ending_sequences << ending_seq
      @all_stem_sequences << stem_seq
    end
    @all_stem_sequences.sort! { |a,b| b.length <=> a.length || a <=> b }.uniq!
    @all_ending_sequences.sort! { |a,b| b.length <=> a.length || a <=> b }.uniq!
  end

  def get_ending_sequence(ending)
    @all_ending_sequences.detect { |ending_seq| ending =~ /^#{ending_seq}/ }
  end

  def get_stem_sequence(stem)
    @all_stem_sequences.detect { |stem_seq| stem =~ /#{stem_seq}$/ }
  end

  def new_stem_and_ending(stem, ending)
    ending_sequence = get_ending_sequence(ending)
    stem_sequence   = get_stem_sequence(stem)
    euphonic_change = @all_contracts[stem_sequence][ending_sequence]
    if euphonic_change
      new_stem = stem.sub(/#{stem_sequence}$/, '')
      new_ending = ending.sub(/^#{ending_sequence}/, euphonic_change)
    else
      new_stem = stem
      new_ending = ending
    end
    return [new_stem, new_ending]
  end

  def new_form(stem, ending)
    new_stem, new_ending = new_stem_and_ending(stem, ending)
    new_form = new_stem + new_ending
    if new_form =~ /--BAD--/
      return nil
    elsif new_form =~ /μμμ/ # avoid forms like πεπεμμμαι
      new_form.gsub!(/μμμ/, 'μμ')
    end
    return new_form
  end
end
