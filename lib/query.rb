def query(q, no_cache=false)
  r = ResultSet.new(query: q, no_cache: no_cache)
  r.run()

  $result_sets << r
  r
end
