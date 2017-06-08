$result_sets = []
CHARS = ('a'..'z').to_a

class ResultSet
  attr_reader :query
  attr_reader :cols
  attr_reader :rows
  attr_reader :show_called

  def initialize(args={})
    @storage = "#{$config[:default_storage]}.default.exalt_"
    @query = args[:query]

    if @query.include? @storage
      @no_cache = true
    else
      @no_cache = args[:no_cache]
    end

    @show_called = false
  end

  def run
    if @no_cache == false
      $presto.run("DROP TABLE IF EXISTS #{table}")

      query = """
      CREATE TABLE #{table} AS
      #{@query}
      """
    else
      query = @query
    end

    puts query

    cols, @rows = $presto.run(query)

    puts @rows

    @cols = []

    cols.each do |c|
      @cols << c.name
    end
  end

  def each
    @rows.each do |r|
      row = {}

      @cols.each_with_index do |c, idx|
        row[c.to_sym] = r[idx]
      end

      yield row
    end
  end

  def table
    @table ||= "#{@storage}#{gen_table_name}"
  end

  def show(num=10)
    @show_called = true
  end

  private

  def gen_table_name
    name = ""

    $result_sets.count.to_s.split('').each do |c|
      name = name + CHARS[c.to_i]
    end

    name
  end
end

