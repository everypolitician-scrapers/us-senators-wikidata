#!/bin/env ruby
# encoding: utf-8

require 'json'
require 'pry'
require 'rest-client'
require 'scraperwiki'
require 'wikidata/fetcher'
require 'mediawiki_api'

def members
  morph_api_url = 'https://api.morph.io/tmtmtmtm/us-congress-members/data.json'
  morph_api_key = ENV["MORPH_API_KEY"]
  result = RestClient.get morph_api_url, params: {
    key: morph_api_key,
    query: "select DISTINCT(identifier__wikipedia) AS wikiname from data WHERE house = 'sen'"
  }
  JSON.parse(result, symbolize_names: true)
end

EveryPolitician::Wikidata.scrape_wikidata(names: { en: members.map { |w| w[:wikiname] } })
warn EveryPolitician::Wikidata.notify_rebuilder
