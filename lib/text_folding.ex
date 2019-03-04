defmodule TextWrap do
  use Memoize
  @limit 30
  @infinity 100_000_000_000

  def wrap(string) do
    words = String.split(string, " ")
    lengths = Enum.map(words, &String.length/1)
    {cost, wrap_ats} = TextWrap.min_cost(lengths, length(lengths) - 1)
    IO.inspect {cost, wrap_ats}, label: "cost"

    # Print wrapped text
    Enum.chunk_every([1] ++ wrap_ats ++ [length(words)], 2, 1,:discard)
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
        # white_spaces = String.duplicate(" ", @limit - len)
        # IO.puts "#{line}#{white_spaces}(#{len}/#{@limit})"
        white_spaces = String.duplicate(".", 30 - len)
        IO.puts "#{line}#{white_spaces}(#{len}/#{@limit})"
      end)
  end

  # Calculate optimized accumulated cost from 0 to n
  def min_cost(lengths, n) when n == 0 do
    # Just return 0 if there's no word
    {TextWrap.line_cost(lengths, 0, 0), []}
  end

  defmemo min_cost(lengths, n) do
    (0..n)
      # We want to calulate all combination of text wraps.
      # We wrap text at posision x in the bollow function.
      # min_cost(lengths, wrap_at) is minimum cost until wrap_at.
      # line_cost(lengths, wrap_at + 1, n) is a cost of one line after wrap_at
      |> Enum.map(
        fn(wrap_at) ->
          if wrap_at == n do
            {TextWrap.line_cost(lengths, 0, n), []}
          else
            {prev_cost, prev_wrap_at} = min_cost(lengths, wrap_at)
            new_line_cost = TextWrap.line_cost(lengths, wrap_at + 1, n)
            cost = prev_cost + new_line_cost
            wrap_ats = prev_wrap_at ++ [wrap_at]
            {cost, wrap_ats}
          end
        end)
      # Take minimum cost
      |> Enum.min_by(fn({cost, _wrap_ats}) -> cost end)
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

  def trailing_white_spaces(_, from, to) when from > to do
    raise "Something is very wrong"
  end
end

Application.ensure_all_started(:memoize)

# target = "aaa bb cc dddddd"
target = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

TextWrap.wrap(target)
