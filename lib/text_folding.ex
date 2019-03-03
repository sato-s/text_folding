defmodule TextFolding do
  use Memoize
  @limit 20
  @infinity 100_000_000_000

  # Calculate optimized accumulated cost from 0 to n
  def min_cost(_lengths, n) when n == 0 do
    # Just return 0 if there's no word
    0
  end

  defmemo min_cost(lengths, n) do
    (0..n-1)
      # We want to calulate all combination of folding.
      # We fold text at posision x in the bollow function.
      # min_cost(lengths, x) is minimum cost until x.
      # line_cost(lengths, x + 1, n) is a cost of one line after x
      |> Enum.map(fn(x) -> min_cost(lengths, x) + TextFolding.line_cost(lengths, x + 1, n) end)
      # Take minimum cost
      |> Enum.min
  end

  defmemo line_cost(lengths, from, to) do
    if trailing_white_spaces(lengths, from, to) < 0 do
      # Return (almost) infinity cost if words in from-to can't arrange in one line.
      @infinity
    else
      :math.pow(trailing_white_spaces(lengths, from, to), 2)
    end
  end

  # Count trailing white spaces of from-to in lengths array
  def trailing_white_spaces(lengths, from, to) when from == to do
    # if from == to, we only have one word.
    # Just return limit minus word length
    @limit - Enum.at(lengths, from)
  end

  def trailing_white_spaces(lengths, from, to) when from != to do
    trailing_white_spaces(lengths, from, to - 1) - Enum.at(lengths, to) - 1
  end
end

Application.ensure_all_started(:memoize)

target = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

lengths = String.split(target, " ")
  |> Enum.map(&String.length/1)
  |> IO.inspect

TextFolding.min_cost(lengths, length(lengths) - 1)
  |> IO.inspect
