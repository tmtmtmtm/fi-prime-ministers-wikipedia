#!/bin/env ruby
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'wikidata_ids_decorator'

require_relative 'lib/date_dotted'
require_relative 'lib/date_partial'
require_relative 'lib/remove_notes'
require_relative 'lib/scraped_wikipedia_officeholders'
require_relative 'lib/unspan_all_tables'
require_relative 'lib/wikipedia_officeholder_page'
require_relative 'lib/wikipedia_officeholder_row'

# The Wikipedia page with a list of officeholders
class ListPage < WikipediaOfficeholderPage
  decorator RemoveNotes
  decorator WikidataIdsDecorator::Links
  decorator UnspanAllTables

  def wanted_tables
    tables_with_header('coalition').first
  end
end

# Each officeholder in the list
class HolderItem < WikipediaOfficeholderRow
  def columns
    %w[_ordinal _photo name start_date end_date _duration _color _party _election _coalition cabinet]
  end

  def start_date_str
    start_date_cell.text.tidy
  end

  def end_date_str
    return if end_date_cell.text.include? 'Incumbent'

    end_date_cell.text.tidy
  end

  def dateclass
    Date::Partial
  end
end

url = ARGV.first || abort("Usage: #{$0} <url to scrape>")
puts Scraped::Wikipedia::OfficeHolders.new(url => ListPage).to_csv
