#!/bin/env ruby
# encoding: utf-8

require 'wikidata/fetcher'

sparq = <<EOQ
  SELECT DISTINCT ?item ?start ?end WHERE {
    ?item p:P39 ?ps .
    ?ps ps:P39 wd:Q13217683 ; pq:P580 ?start .
    OPTIONAL { ?ps pq:P582 ?end }

    FILTER(!BOUND(?end) || (?end >= "1981-01-01T00:00:00Z"^^xsd:dateTime))
  }
EOQ
ids = EveryPolitician::Wikidata.sparql(sparq)

EveryPolitician::Wikidata.scrape_wikidata(ids: ids, batch_size: 200)
