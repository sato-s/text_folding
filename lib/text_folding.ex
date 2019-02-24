defmodule TextFolding do
  @limit 6
  # strings => [2, 4, 5, 6]
  # F[]
  def fold(remaining_words, lengths_array) when length(remaining_words) == 0 do
    # Enum.each(lengths_array, &(IO.inspect &1, charlists: :as_lists, label: "line"))
    # Enum.each(lengths_array, &(IO.inspect line_cost(&1), label: "cost"))
    lengths_array
    |> TextFolding.cost
    |> IO.inspect(label: "Sum cost")
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
    Enum.map(lengths_array, &TextFolding.line_cost/1)
    |> Enum.sum
  end

  # Count unnecessary trailing white spaces
  def line_cost(lengths) do
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
lorem = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

# String.split(string, " ")
#   |> Enum.map(&String.length/1)
#   |> TextFolding.fold([[]])
#   |> IO.inspect
  #
String.split(lorem, " ")
  |> Enum.map(&String.length/1)
  |> TextFolding.fold([[]])
  |> IO.inspect
