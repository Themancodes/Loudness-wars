require 'net/http'
require 'nokogiri'
require 'csv'

class Record
    attr_accessor :artist_name, :album_name, :year, :avg_dr, :min_dr, :max_dr, :codec, :source

    def self.headers
        ["artist_name", "album_name", "year", "avg_dr", "min_dr", "max_dr", "codec", "source"]
    end

    def to_s
        x.artist_name + ": " + x.album_name
    end

    def to_a
        [artist_name, album_name, year, avg_dr, min_dr, max_dr, codec, source]
    end


end

def extract_row(doc, row)
    record = Record.new
    doc.xpath("//body/div/div[3]/table/tbody/tr[#{row}]").first.children.each_with_index do |child, index|
        value = child.text.gsub(/[\t\n]/, '')
        case index
        when 1
            record.artist_name = value
        when 3
            record.album_name = value
        when 5
            record.year = value
        when 7
            record.avg_dr = value
        when 9
            record.min_dr = value
        when 11
            record.max_dr = value
        when 13
            record.codec = value
        when 15
            record.source = value
        end
    end
    record
end

records = []

(1..10).each do |page_number|
    uri = URI("https://dr.loudness-war.info/album/list/dr/desc/#{page_number}")
    webpage = Net::HTTP.get(uri)
    doc = Nokogiri::HTML(webpage)

    
    (1..69).each do |row|
        records.append(extract_row(doc, row))
    end
    pp records
end

@file = "loudness.csv"

CSV.open(@file, "r+") do |csv|
    csv << Record.headers
    records.each do |record|
        csv << record.to_a
    end
end