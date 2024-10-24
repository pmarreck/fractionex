defmodule FractionalTest do
  alias Fractional, as: F

  import Kernel,
    except: [
      +: 2,
      -: 2,
      *: 2,
      /: 2,
      <: 2,
      >: 2,
      ==: 2,
      !=: 2,
      trunc: 1,
      rem: 2,
      abs: 1,
      inspect: 1
    ]

  import F,
    only: [+: 2, -: 2, *: 2, /: 2, <: 2, >: 2, ==: 2, !=: 2, trunc: 1, rem: 2, abs: 1, inspect: 1]

  describe "new/2" do
    test "creates a new fractional" do
      assert {:fractional, 1, 2} == F.new(1, 2)
    end

    test "shrink the fractional" do
      assert F.new(1, 2) == F.new(2, 4)
    end

    test "sets up the right fraction when you try to create a new fractional from a float" do
      assert F.new(401, 2) == F.new(200.5)
    end
  end

  describe "convert_fraction_to_fractional/1" do
    test "converts a fractional string to a fractional" do
      assert F.new(1, 3) == F.convert_fraction_to_fractional("4/12")
    end
  end

  describe "move_negatively_signed_denominators_to_numerator/1" do
    test "moves the negative sign from the denominator to the numerator" do
      assert F.new(-1, 2) ==
               F.move_negatively_signed_denominators_to_numerator({:fractional, 1, -2})
    end
  end

  describe "addition" do
    test "adds two fractionals" do
      assert F.new(1, 2) == F.new(1, 4) + F.new(1, 4)
      assert F.new(17, 14) == F.new(1, 2) + F.new(5, 7)
    end
  end

  describe "subtraction" do
    test "subtracts two fractionals" do
      assert F.new(-3, 14) == F.new(1, 2) - F.new(5, 7)
    end
  end

  describe "multiplication" do
    test "multiplies two fractionals" do
      assert F.new(3, 7) == F.new(1, 2) * F.new(6, 7)
    end
  end

  describe "division" do
    test "divides two fractionals" do
      assert F.new(7, 12) == F.new(1, 2) / F.new(6, 7)
    end
  end

  describe "gcd" do
    test "calculates the greatest common divisor" do
      assert 5 == F.gcd(10, 25)
    end
  end

  describe "abs" do
    test "returns the absolute value of a fractional" do
      assert F.new(1, 2) == F.abs(F.new(-2, 4))
    end

    test "asserts that a zero fraction isn't larger than a 0.01 fraction" do
      assert F.new(0) < F.abs(F.new(0.01))
    end
  end

  describe "rem" do
    test "returns the fractional part less than 1 of a fractional" do
      assert F.new(0.3) == F.rem(F.new(3.3))
    end
  end

  describe "trunc" do
    test "returns the whole part of a fractional" do
      assert F.new(3) == F.trunc(F.new(3.3))
    end
  end

  describe "pi as an approximate fraction" do
    test "returns the value of pi as a fractional to a given place" do
      # reduced from 31415926535/10000000000
      pi_to_10 = F.new(6_283_185_307, 2_000_000_000)
      assert pi_to_10 == F.pi(10)
      assert F.to_float(pi_to_10) == 3.1415926535
    end
  end
end
