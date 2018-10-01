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

morph_names = members.map { |w| w[:wikiname] }

url = "https://en.wikipedia.org/wiki/115th_United_States_Congress"
wp_names = EveryPolitician::Wikidata.wikipedia_xpath(
  url: url,
  after: '//span[@id="Members"]',
  before: '//span[@id="House_of_Representatives_3"]',
  xpath: './/li//a[not(@class="new")]/@title',
)
raise "No names at #{url}" if wp_names.empty?

EveryPolitician::Wikidata.scrape_wikidata(names: { en: morph_names | wp_names })
