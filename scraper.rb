#!/bin/env ruby
# encoding: utf-8

require 'json'
require 'pry'
require 'rest-client'
require 'scraperwiki'
require 'wikidata/fetcher'
require 'mediawiki_api'

# TODO remove this once all members are have suitable P39s
def members
  morph_api_url = 'https://api.morph.io/tmtmtmtm/us-congress-members/data.json'
  morph_api_key = ENV["MORPH_API_KEY"]
  result = RestClient.get morph_api_url, params: {
    key: morph_api_key,
    query: "select DISTINCT(identifier__wikidata) AS wikidata from data WHERE house = 'sen'"
  }
  JSON.parse(result, symbolize_names: true)
end
morph = members.map { |w| w[:wikidata] }

sparq = <<EOQ
  SELECT DISTINCT ?item ?start ?end WHERE {
    ?item p:P39 ?ps .
    ?ps ps:P39 wd:Q13217683 ; pq:P580 ?start .
    OPTIONAL { ?ps pq:P582 ?end }

    FILTER(!BOUND(?end) || (?end >= "1981-01-01T00:00:00Z"^^xsd:dateTime))
  }
EOQ
ids = EveryPolitician::Wikidata.sparql(sparq)

EveryPolitician::Wikidata.scrape_wikidata(ids: ids | morph, batch_size: 200)
