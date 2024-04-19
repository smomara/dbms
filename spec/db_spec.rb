require 'rspec'

describe 'database' do
  # Clear the test database before each test
  before(:each) do
    `rm -f test.db`
  end

  # Helper method to run database script commands and capture output
  def run_script(commands)
    raw_output = nil
    IO.popen("./db test.db", "r+") do |pipe|
      commands.each { |command| pipe.puts command }
      pipe.close_write
      raw_output = pipe.gets(nil)  # Read the entire output
    end
    raw_output.split("\n")  # Return the output split into lines
  end

  context 'when managing data' do
    it 'inserts and retrieves a row' do
      result = run_script([
        "insert 1 user1 person1@example.com",
        "select",
        ".exit",
      ])
      expect(result).to match_array([
        "db > Executed.",
        "db > (1, user1, person1@example.com)",
        "Executed.",
        "db > ",
      ])
    end

    it 'prints error message when table is full' do
      script = (1..1401).map { |i| "insert #{i} user#{i} person#{i}@example.com" }
      script << ".exit"
      result = run_script(script)
      expect(result[-2]).to eq('db > Error: Table full.')
    end
  end

  context 'when validating input' do
    it 'allows inserting strings that are the maximum length' do
      long_username = "a" * 32
      long_email = "a" * 255
      result = run_script([
        "insert 1 #{long_username} #{long_email}",
        "select",
        ".exit",
      ])
      expect(result).to match_array([
        "db > Executed.",
        "db > (1, #{long_username}, #{long_email})",
        "Executed.",
        "db > ",
      ])
    end

    it 'prints error message if strings are too long' do
      long_username = "a" * 33
      long_email = "a" * 256
      result = run_script([
        "insert 1 #{long_username} #{long_email}",
        "select",
        ".exit",
      ])
      expect(result).to match_array([
        "db > String is too long.",
        "db > Executed.",
        "db > ",
      ])
    end

    it 'prints an error message if id is negative' do
      result = run_script([
        "insert -1 cstack foo@bar.com",
        "select",
        ".exit",
      ])
      expect(result).to match_array([
        "db > ID must be positive.",
        "db > Executed.",
        "db > ",
      ])
    end
  end

  context 'when testing persistence' do
    it 'keeps data after closing connection' do
      run_script(["insert 1 user1 person1@example.com", ".exit"])
      result = run_script(["select", ".exit"])
      expect(result).to match_array([
        "db > (1, user1, person1@example.com)",
        "Executed.",
        "db > ",
      ])
    end
  end

  context 'when querying system properties' do
    it 'prints constants' do
      result = run_script([".constants", ".exit"])
      expect(result).to match_array([
        "db > Constants:",
        "ROW_SIZE: 293",
        "COMMON_NODE_HEADER_SIZE: 6",
        "LEAF_NODE_HEADER_SIZE: 10",
        "LEAF_NODE_CELL_SIZE: 297",
        "LEAF_NODE_SPACE_FOR_CELLS: 4086",
        "LEAF_NODE_MAX_CELLS: 13",
        "db > ",
      ])
    end
  end

  context 'B-tree operations' do
    it 'allows printing out the structure of a one-node btree' do
      script = [3, 1, 2].map do |i|
        "insert #{i} user#{i} person#{i}@example.com"
      end
      script << ".btree"
      script << ".exit"
      result = run_script(script)

      expect(result).to match_array([
        "db > Executed.",
        "db > Executed.",
        "db > Executed.",
        "db > Tree:",
        "leaf (size 3)",
        "\t- 0 : 1",
        "\t- 1 : 2",
        "\t- 2 : 3",
        "db > "
      ])
    end
  end

  context 'when inserting' do
    it 'prints an error message if there is a duplicate id' do
      script = [
        "insert 1 user1 person1@example.com",
        "insert 1 user1 person1@example.com",
        "select",
        ".exit",
      ]
      result = run_script(script)

      expect(result).to match_array([
        "db > Executed.",
        "db > Error: Duplicate key.",
        "db > (1, user1, person1@example.com)",
        "Executed.",
        "db > ",
      ])
    end
  end
end