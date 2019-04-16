def paginated_response(count, data)
  {
    "meta"  => {
      "count" => count,
      "limit" => kind_of(Integer),
      "offset" => kind_of(Integer)
    },
    "links" => a_hash_including(
      "first" => a_string_including("offset=0"),
      "last"  => a_string_including("offset=")
    ),
    "data"  => data
  }
end
