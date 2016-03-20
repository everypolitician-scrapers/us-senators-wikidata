#!/bin/env ruby
# encoding: utf-8

require 'json'
require 'pry'
require 'rest-client'
require 'scraperwiki'
require 'wikidata/fetcher'
require 'mediawiki_api'
require 'active_support/inflector'

def members
  morph_api_url = 'https://api.morph.io/tmtmtmtm/us-congress-members/data.json'
  morph_api_key = ENV["MORPH_API_KEY"]
  result = RestClient.get morph_api_url, params: {
    key: morph_api_key,
    query: "select DISTINCT(identifier__wikipedia) AS wikiname from data WHERE house = 'sen'"
  }
  JSON.parse(result, symbolize_names: true)
end

names = {}
(97 .. 114).each do |cid|
  names[cid] = EveryPolitician::Wikidata.wikipedia_xpath( 
    url: "https://en.wikipedia.org/wiki/#{ActiveSupport::Inflector.ordinalize cid}_United_States_Congress",
    after: '//span[@id="Members"]',
    before: '//span[@id="House_of_Representatives_3"]',
    xpath: './/li//a[not(@class="new")]/@title',
  )
end

morph_names = members.map { |w| w[:wikiname] }
toget = morph_names | names.values.flatten.uniq

toget.shuffle.each_slice(100) do |sliced|
  EveryPolitician::Wikidata.scrape_wikidata(names: { en: sliced })
end
