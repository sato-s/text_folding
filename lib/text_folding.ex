defmodule TextFolding do
  use Memoize
  @limit 30
  @infinity 100_000_000_000

  def fold(string) do
    words = String.split(string, " ")
    lengths = Enum.map(words, &String.length/1)
    {cost, foldings} = TextFolding.min_cost(lengths, length(lengths) - 1)
    IO.inspect {cost, foldings}, label: "cost"

    # Print folded text
    Enum.chunk_every([1] ++ foldings ++ [length(words)], 2, 1,:discard)
      |> Enum.map(fn(x) ->
        from = List.first(x)
        to = List.last(x)
        if from == 1 do
          Enum.slice(words, (0..to))
        else
          Enum.slice(words, (from+1..to))
        end
      end)
      |> Enum.each(fn(words) ->
        line =  Enum.join(words, " ")
        len = String.length(line)
        white_spaces = String.duplicate("␣", 30 - len)
        IO.puts "#{line}#{white_spaces}(#{len})"
      end)
  end

  # Calculate optimized accumulated cost from 0 to n
  def min_cost(lengths, n) when n == 0 do
    # Just return 0 if there's no word
    {TextFolding.line_cost(lengths, 0, 0), []}
  end

  defmemo min_cost(lengths, n) do
    (0..n)
      # We want to calulate all combination of folding.
      # We fold text at posision x in the bollow function.
      # min_cost(lengths, fold_at) is minimum cost until fold_at.
      # line_cost(lengths, fold_at + 1, n) is a cost of one line after fold_at
      |> Enum.map(
        fn(fold_at) ->
          if fold_at == n do
            {TextFolding.line_cost(lengths, 0, n), []}
          else
            {prev_cost, prev_fold_at} = min_cost(lengths, fold_at)
            new_line_cost = TextFolding.line_cost(lengths, fold_at + 1, n)
            cost = prev_cost + new_line_cost
            foldings = prev_fold_at ++ [fold_at]
            {cost, foldings}
          end
        end)
      # Take minimum cost
      |> Enum.min_by(fn({cost, _foldings}) -> cost end)
  end

  def line_cost(lengths, from, to) do
    if trailing_white_spaces(lengths, from, to) < 0 do
      # Return (almost) infinity cost if words in from-to can't arrange in one line.
      @infinity
    else
      :math.pow(trailing_white_spaces(lengths, from, to), 3)
    end
  end

  # Count trailing white spaces of from-to in lengths array
  def trailing_white_spaces(lengths, from, to) when from == to do
    # if from == to, we only have one word.
    # Just return limit minus word length
    @limit - Enum.at(lengths, from)
  end

  defmemo trailing_white_spaces(lengths, from, to) when from != to do
    trailing_white_spaces(lengths, from, to - 1) - Enum.at(lengths, to) - 1
  end
end

Application.ensure_all_started(:memoize)

target = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

TextFolding.fold(target)
