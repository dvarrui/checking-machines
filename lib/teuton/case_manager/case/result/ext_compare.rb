# frozen_string_literal: true

# Extension of Result class
class Result
  def eq(input)
    # Return true when content is equal than input
    @expected = input

    case input.class.to_s
    when "Fixnum"
      value = @content[0].to_i
      puts "[WARN] Fixnum is a Ruby deprecated class!"
      puts "       (Upgrade your Ruby version)"
    when "Float"
      value = @content[0].to_f
    when "Integer"
      value = @content[0].to_i
    when "String"
      value = @content[0].to_s
    else
      value = @content[0]
    end
    value == input
  end
  alias_method :eq?, :eq
  alias_method :equal, :eq
  alias_method :equal?, :eq
  alias_method :is_equal?, :eq

  def neq(external)
    @expected = "Not equal to #{external}"

    case external.class.to_s
    when "Fixnum"
      internal = @content[0].to_i
      puts "[WARN] Fixnum class is deprecated!"
      puts "       Upgrade your Ruby version."
    when "Float"
      internal = @content[0].to_f
    when "Integer"
      internal = @content[0].to_i
    else
      internal = @content[0]
    end
    internal != external
  end
  alias_method :neq?, :neq
  alias_method :not_equal, :neq
  alias_method :not_equal?, :neq

  def ge(input)
    @expected = "Greater or equal to #{input}"
    return false if @content.nil? || @content[0].nil?

    value = @content[0]
    case input.class.to_s
    when "Fixnum"
      value = @content[0].to_i
      puts "[WARN] Fixnum class is deprecated!"
      puts "       Upgrade your Ruby version."
    when "Float"
      value = @content[0].to_f
    when "Integer"
      value = @content[0].to_i
    end
    value >= input
  end
  alias_method :greater_or_equal, :ge
  alias_method :greater_or_equal?, :ge

  def gt(input)
    @expected = "Greater than #{input}"
    return false if @content.nil? || @content[0].nil?

    value = @content[0]
    case input.class.to_s
    when "Fixnum"
      value = @content[0].to_i
      puts "[WARN] Fixnum class is deprecated!"
      puts "       Upgrade your Ruby version."
    when "Float"
      value = @content[0].to_f
    when "Integer"
      value = @content[0].to_i
    end
    value > input
  end
  alias_method :greater, :gt
  alias_method :greater_than, :gt

  def le(input)
    @expected = "Lesser or equal to #{input}"

    return false if @content.nil? || @content[0].nil?

    value = @content[0]
    case input.class.to_s
    when "Fixnum"
      value = @content[0].to_i
      puts "[WARN] Fixnum class is deprecated!"
      puts "       Upgrade your Ruby version."
    when "Float"
      value = @content[0].to_f
    when "Integer"
      value = @content[0].to_i
    end
    value <= input
  end
  alias_method :lesser_or_equal, :le
  alias_method :lesser_or_equal?, :le

  def lt(input)
    @expected = "Lesser than #{input}"
    return false if @content.nil? || @content[0].nil?

    value = @content[0]
    case input.class.to_s
    when "Fixnum"
      value = @content[0].to_i
      puts "[WARN] Fixnum class is deprecated!"
      puts "       Upgrade your Ruby version."
    when "Float"
      value = @content[0].to_f
    when "Integer"
      value = @content[0].to_i
    end
    value < input
  end
  alias_method :lesser, :lt
  alias_method :smaller, :lt
  alias_method :lesser_than, :lt

  # Return 'true' if the parameter value is near to the target value.
  # To get this we consider a 10% desviation or less, as an acceptable result.
  def near_to?(input)
    @expected = "Is near to #{input}"
    return false if @content.nil?

    target = @content[0].to_f
    desv = (target * 10.0) / 100.0
    return true if (target - input.to_f).abs.to_f <= desv

    false
  end
  alias_method :near_to, :near_to?
  alias_method :near?, :near_to?
  alias_method :near, :near_to?
end
