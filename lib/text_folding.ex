defmodule TextWrap do
  use Memoize
  @limit 30
  @infinity 100_000_000_000

  def wrap(string) do
    words = String.split(string, " ")
    lengths = Enum.map(words, &String.length/1)
    {cost, wraps} = TextWrap.cost(lengths, length(lengths) - 1)
    IO.inspect {cost, wraps}, label: "cost"

    # Print wrapped text
    Enum.chunk_every([1] ++ wraps ++ [length(words)], 2, 1,:discard)
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
  def cost(lengths, n) when n == 0 do
    # Just return 0 if there's no word
    {TextWrap.line_cost(lengths, 0, 0), []}
  end

  defmemo cost(lengths, n) do
    costs = (0..n-1)
      |> Enum.map(
        fn(wrap) ->
          {prev_cost, prev_wrap} = cost(lengths, wrap)
          new_line_cost = TextWrap.line_cost(lengths, wrap + 1, n)
          cost = prev_cost + new_line_cost
          wraps = prev_wrap ++ [wrap]
          {cost, wraps}
        end)
    one_line_cost = {TextWrap.line_cost(lengths, 0, n), []}
    [one_line_cost | costs]
      |> Enum.min_by(fn({cost, _wraps}) -> cost end)
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

  def trailing_white_spaces(_, from, to) when from > to do
    raise "Something is very wrong"
  end

  def trailing_white_spaces(_, from, to) when from > to do
    raise "Something is very wrong"
  end

  defmemo trailing_white_spaces(lengths, from, to) when from != to do
    trailing_white_spaces(lengths, from, to - 1) - Enum.at(lengths, to) - 1
  end

end

Application.ensure_all_started(:memoize)

# target = "aaa bb cc dddddd"
target = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

TextWrap.wrap(target)
