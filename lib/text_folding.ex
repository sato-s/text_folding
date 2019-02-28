defmodule TextFolding do
  use Memoize
  @limit 6
  # strings => [2, 4, 5, 6]
  # F[]
  def fold(remaining_words, lengths_array) when length(remaining_words) == 0 do
    # Enum.each(lengths_array, &(IO.inspect &1, charlists: :as_lists, label: "line"))
    # Enum.each(lengths_array, &(IO.inspect line_cost(&1), label: "cost"))
    lengths_array
    |> TextFolding.cost
    # |> IO.inspect(label: "Sum cost")
  end

  # TODO
  # this just returns possible folding combination
  def fold(remaining_words, lengths_array) do
    [head | tail] = remaining_words
    new_line = append_new_line(lengths_array, head)
    same_line = append_same_line(lengths_array, head)
    fold(tail, same_line)
    fold(tail, new_line)
  end

  # Append a word as a new line
  # [[1], [1]] => [[1], [1], [1]]
  def append_new_line(lengths_array, word) do
    lengths_array ++ [[word]]
  end

  # Append a word as a last word of existing line
  # [[1], [1]] => [[1], [1, 1]]
  def append_same_line(lengths_array, word) do
    init = Enum.take(lengths_array, length(lengths_array) -1)
    last = Enum.at(lengths_array, -1) ++ [word]
    init ++ [last]
  end

  # Calculate cost of folding of entire text
  # Input: work length array of text
  # Ex: [[10, 10, 9], [10, 18]]
  # Output: cost of the text
  def cost(lengths_array) do
    trailing_spaces(lengths_array)
    |> Enum.reduce(0, fn (x, acc) -> :math.pow(x, 3) + acc end)
  end

  # Input length array, returns white spaces array
  def trailing_spaces([[]]) do
    []
  end

  defmemo trailing_spaces(lengths_array) do
    {previous_lengths_array, current, popped_new_line?} = TextFolding.pop(lengths_array)
    if current >= @limit do
      [100_000_000]
    end
    previous_white_spaces = trailing_spaces(previous_lengths_array)

    if popped_new_line? do
      previous_white_spaces ++ [@limit - current]
    else
      while_spaces_of_last_line = List.last(previous_white_spaces)
                                  |> (&(&1 - (current + 1))).()
      if while_spaces_of_last_line < 0 do
        [100_000_000]
      else
        previous_white_spaces
        |> Enum.drop(-1)
        |> (fn(x) ->  x ++ [while_spaces_of_last_line] end).()
      end
    end
  end

  def pop([[]]) do
    raise "Can't pop any more"
  end

  def pop([[x]]) do
    {[[]], x, true}
  end

  def pop(lengths_array) do
    init = Enum.drop(lengths_array, -1)
    last = List.last(lengths_array)
    if length(last) == 1 do
      {init, List.first(last), true}
    else
      {init ++ [Enum.take(last, length(last) - 1)], List.last(last), false}
    end
  end

  # Count unnecessary trailing white spaces
  defmemo line_cost(lengths) do
    c = @limit - (Enum.sum(lengths) + Enum.count(lengths) - 1)
    if c < 0 do
      # Return (almost) infinity cost if this exceeds @limit
      100_000_000
    else
      :math.pow(c, 3)
    end
  end

  def to_length_array(string) do
    String.split(string, " ")
      |> Enum.map(&String.length/1)
  end

end

# string = "aaa bb cc ddddd"

# TextFolding.to_length_array(string)
#   |> IO.inspect
#
# TextFolding.line_cost([1,2])
#   |> IO.inspect
#
# TextFolding.cost([[3, 2], [2], [5] ])
#   |> IO.inspect
#
# TextFolding.cost([[3], [2, 2], [5] ])
#   |> IO.inspect
#
# TextFolding.append_new_line([[1], [1]], 1)
#   |> IO.inspect
#
# TextFolding.append_same_line([[1], [1]], 1)
#   |> IO.inspect
# lorem = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
#
# lorem = "aa bb cccc asa"

  #
Application.ensure_all_started(:memoize)
IO.inspect "---"
TextFolding.trailing_spaces([[1,2],[3, 2, 1]])
  |> IO.inspect

IO.inspect "---"
TextFolding.cost([[1,2],[3, 2, 1]])
  |> IO.inspect

IO.inspect "lorem"
# lorem = "aaa bb cc ddddd"
lorem = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
String.split(lorem, " ")
  |> Enum.map(&String.length/1)
  |> TextFolding.fold([[]])
