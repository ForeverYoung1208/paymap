# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)



require 'csv'    

csv = CSV.read('db/dod6.csv', :col_sep => ';', :headers => true, :encoding => 'windows-1251:utf-8')

csv.each do |row|
  Transfert.create!(row.to_hash)
end


