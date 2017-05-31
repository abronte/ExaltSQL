$result_sets = []
CHARS = ('a'..'z').to_a

# memory: memory.default.exalt_
# disk: raptor.default.exalt_
class ResultSet
  attr_reader :query
  attr_reader :cols
  attr_reader :rows
  attr_reader :show_called

  STORAGE = "memory.default.exalt_"
  # STORAGE = "raptor.default.exalt_"

  def initialize(args={})
    @query = args[:query]

    if @query.include? STORAGE
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

  def table
    # @table ||= "#{STORAGE}_#{('a'..'z').to_a.shuffle[0,20].join}"
    @table ||= "#{STORAGE}#{gen_table_name}"
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

