defmodule TextFolding do
  use Memoize
  @limit 20
  @infinity 100_000_000_000

  # Calculate accumulated cost from 0 to j
  def min_cost(_lengths, j) when j == 0 do
    0
  end

  defmemo min_cost(lengths, j) do
    (0..j-1)
      |> Enum.map(fn(x) -> min_cost(lengths, x) + TextFolding.line_cost(lengths, x + 1, j) end)
      |> Enum.min
  end

  defmemo line_cost(lengths, i, j) do
    if trailing_white_spaces(lengths, i, j) < 0 do
      # Return (almost) infinity cost if words in i-j can't arrange in one line.
      @infinity
    else
      :math.pow(trailing_white_spaces(lengths, i, j), 2)
    end
  end

  def trailing_white_spaces(lengths, i, j) when i == j do
    @limit - Enum.at(lengths, i)
  end

  def trailing_white_spaces(lengths, i, j) when i != j do
    trailing_white_spaces(lengths, i, j - 1) - Enum.at(lengths, j) - 1
  end
end

Application.ensure_all_started(:memoize)

# target = "aa bb cccc asa"
target = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

lengths = String.split(target, " ")
  |> Enum.map(&String.length/1)
  |> IO.inspect

TextFolding.min_cost(lengths, length(lengths) - 1)
  |> IO.inspect
