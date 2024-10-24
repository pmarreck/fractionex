defmodule Fractional do
  @moduledoc """
  Fractional numbers module
  """

  # Importing Kernel but excluding the operators
  alias Kernel, as: K

  import K,
    except: [
      +: 2,
      -: 2,
      *: 2,
      /: 2,
      >: 2,
      <: 2,
      ==: 2,
      !=: 2,
      trunc: 1,
      rem: 2,
      abs: 1,
      inspect: 1
    ]

  defguard is_fractional(term)
           when K.==(tuple_size(term), 3) and K.==(elem(term, 0), :fractional) and
                  is_integer(elem(term, 1)) and is_integer(elem(term, 2))

  def shrink_fractional({_, numerator, denominator} = frac) when is_fractional(frac) do
    reductor = gcd(numerator, denominator)
    {:fractional, trunc(numerator / reductor), trunc(denominator / reductor)}
  end

  def new(numerator, denominator) when is_float(numerator) or is_float(denominator) do
    raise "Cannot create a fractional from floats, please use integers only"
  end

  def new(numerator, denominator) do
    {:fractional, numerator, denominator}
    |> shrink_fractional()
    |> move_negatively_signed_denominators_to_numerator()
  end

  def new({n, d}), do: new(n, d)

  def new(numerator) when is_integer(numerator) do
    {:fractional, numerator, 1}
  end

  def new(frac) when is_binary(frac) do
    convert_fraction_to_fractional(frac)
  end

  def new(num) when is_float(num) do
    # determine how many decimal places are in the float
    decimal_places = String.split(Float.to_string(num), ".") |> List.last() |> String.length()
    new(trunc(num * 10 ** decimal_places), 10 ** decimal_places)
  end

  def new(fr) when is_fractional(fr), do: fr

  def inspect({_, numerator, denominator} = frac) when is_fractional(frac) do
    IO.puts("#Fraction<#{inspect(numerator)}/#{inspect(denominator)} (#{to_float(frac)})>")
    frac
  end

  def inspect(thing), do: Kernel.inspect(thing)

  def move_negatively_signed_denominators_to_numerator({_, numerator, denominator} = frac_d)
      when is_fractional(frac_d) do
    if denominator < 0 do
      {:fractional, -1 * numerator, -1 * denominator}
    else
      frac_d
    end
  end

  @doc """
  Converts a fractional string to a decimal
  ## Examples
  iex> convert_fractional_to_decimal("1/2")
  0.5
  iex> convert_fractional_to_decimal("3/4")
  0.75
  """
  def convert_fraction_to_fractional(fraction) when is_binary(fraction) do
    [numerator, denominator] = String.split(fraction, "/")
    numerator = String.to_integer(numerator)
    denominator = String.to_integer(denominator)

    {:fractional, numerator, denominator}
    |> shrink_fractional()
    |> move_negatively_signed_denominators_to_numerator()
  end

  # addition
  def {:fractional, numerator1, denominator1} + {:fractional, numerator2, denominator2}
      when is_integer(numerator1) and is_integer(denominator1) and is_integer(numerator2) and
             is_integer(denominator2) do
    lcm = lcm(denominator1, denominator2)
    first_frac_multiplier = div(lcm, denominator1)
    second_frac_multiplier = div(lcm, denominator2)
    new_numerator1 = numerator1 * first_frac_multiplier
    new_numerator2 = numerator2 * second_frac_multiplier

    {:fractional, new_numerator1 + new_numerator2, lcm}
    |> shrink_fractional()
    |> move_negatively_signed_denominators_to_numerator()
  end

  def left + right do
    K.+(left, right)
  end

  # subtraction
  def {:fractional, numerator1, denominator1} - {:fractional, numerator2, denominator2}
      when is_integer(numerator1) and is_integer(denominator1) and is_integer(numerator2) and
             is_integer(denominator2) do
    lcm = lcm(denominator1, denominator2)
    first_frac_multiplier = div(lcm, denominator1)
    second_frac_multiplier = div(lcm, denominator2)
    new_numerator1 = numerator1 * first_frac_multiplier
    new_numerator2 = numerator2 * second_frac_multiplier

    {:fractional, new_numerator1 - new_numerator2, lcm}
    |> shrink_fractional()
    |> move_negatively_signed_denominators_to_numerator()
  end

  def left - right do
    K.-(left, right)
  end

  # multiplication
  def {:fractional, numerator1, denominator1} * {:fractional, numerator2, denominator2}
      when is_integer(numerator1) and is_integer(denominator1) and is_integer(numerator2) and
             is_integer(denominator2) do
    {:fractional, numerator1 * numerator2, denominator1 * denominator2}
    |> shrink_fractional()
    |> move_negatively_signed_denominators_to_numerator()
  end

  def left * right do
    K.*(left, right)
  end

  # division
  def {:fractional, numerator1, denominator1} / {:fractional, numerator2, denominator2}
      when is_integer(numerator1) and is_integer(denominator1) and is_integer(numerator2) and
             is_integer(denominator2) do
    {:fractional, numerator1 * denominator2, denominator1 * numerator2}
    |> shrink_fractional()
    |> move_negatively_signed_denominators_to_numerator()
  end

  def left / right do
    K./(left, right)
  end

  # comparison
  def left == right when is_fractional(left) and is_fractional(right) do
    {:fractional, numerator1, denominator1} = left
    {:fractional, numerator2, denominator2} = right
    lcmult = lcm(denominator1, denominator2)
    first_frac_multiplier = lcmult / denominator1
    second_frac_multiplier = lcmult / denominator2
    new_numerator1 = numerator1 * first_frac_multiplier
    new_numerator2 = numerator2 * second_frac_multiplier
    new_numerator1 == new_numerator2
  end

  def left == right do
    K.==(left, right)
  end

  def left != right do
    not (left == right)
  end

  def left > right when is_fractional(left) and is_fractional(right) do
    {:fractional, numerator1, denominator1} = left
    {:fractional, numerator2, denominator2} = right
    lcmult = lcm(denominator1, denominator2)
    first_frac_multiplier = lcmult / denominator1
    second_frac_multiplier = lcmult / denominator2
    new_numerator1 = numerator1 * first_frac_multiplier
    new_numerator2 = numerator2 * second_frac_multiplier
    new_numerator1 > new_numerator2
  end

  def left > right do
    K.>(left, right)
  end

  def left < right when is_fractional(left) and is_fractional(right) do
    {:fractional, numerator1, denominator1} = left
    {:fractional, numerator2, denominator2} = right
    lcmult = lcm(denominator1, denominator2)
    first_frac_multiplier = lcmult / denominator1
    second_frac_multiplier = lcmult / denominator2
    new_numerator1 = numerator1 * first_frac_multiplier
    new_numerator2 = numerator2 * second_frac_multiplier
    new_numerator1 < new_numerator2
  end

  def left < right do
    K.<(left, right)
  end

  def numerator({_, numerator, _} = fr) when is_fractional(fr), do: numerator
  def denominator({_, _, denominator} = fr) when is_fractional(fr), do: denominator

  def abs(fr) when is_fractional(fr) do
    {_, numerator, denominator} = fr
    new(abs(numerator), abs(denominator))
  end

  def abs(a), do: K.abs(a)

  def rem({_, numerator, denominator} = fr) when is_fractional(fr) do
    new(K.rem(numerator, denominator), denominator)
  end

  def rem(a, b), do: K.rem(a, b)

  def trunc(fr) when is_fractional(fr) do
    fr - rem(fr)
  end

  def trunc(a), do: K.trunc(a)
  def gcd(a, 0) when is_integer(a), do: trunc(a)

  def gcd(a, b) when is_integer(a) and is_integer(b),
    do: trunc(gcd(trunc(b), rem(trunc(a), trunc(b))))

  def gcd(a, b) when is_integer(a) and is_integer(b), do: gcd(trunc(a), trunc(b))

  def lcm(a, b) when is_integer(a) and is_integer(b), do: trunc(trunc(a) * trunc(b) / gcd(a, b))
  def lcm(a, b) when is_integer(a) and is_integer(b), do: lcm(trunc(a), trunc(b))

  def lcm_list(list) do
    Enum.reduce(list, 1, fn x, acc -> lcm(trunc(x), acc) end)
  end

  # def to_decimal(fr) when is_fractional(fr) do
  #   import Decimal, only: [div: 2]
  #   {_, numerator, denominator} = fr
  #   Decimal.div(numerator, denominator)
  # end
  def to_integer(fr) when is_fractional(fr) do
    trunc(fr)
  end

  def to_float({_, numerator, denominator} = frac) when is_fractional(frac) do
    numerator / denominator
  end

  def pi(places) when is_integer(places) do
    numerator =
      Stream.resource(
        fn ->
          {1, 0, 1, 1, 3, 3, 0}
        end,
        fn
          {q, r, t, k, n, l, c} when K.<(K.-(K.+(K.*(4, q), r), t), K.*(n, t)) ->
            {[n], {q * 10, 10 * (r - n * t), t, k, div(10 * (3 * q + r), t) - 10 * n, l, c + 1}}

          {q, r, t, k, _n, l, c} ->
            {[],
             {q * k, (2 * q + r) * l, t * l, k + 1, div(q * 7 * k + 2 + r * l, t * l), l + 2, c}}
        end,
        fn s -> s end
      )
      |> Enum.take(places + 1)
      |> Enum.reduce("", fn x, acc -> acc <> Integer.to_string(x) end)
      |> String.to_integer()

    denominator = 10 ** places
    new(numerator, denominator)
  end
end
