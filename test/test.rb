require 'mqtt'
require 'mysql'
require 'json'

begin

mydb = Mysql.connect('localhost', 'root', 'Tag0re123', 'snipeit')

rs = mydb.query "SELECT assets.id, models.name, users.first_name, users.last_name, 
_snipeit_epc, _snipeit_mon, _snipeit_tue, _snipeit_wed, _snipeit_thu, _snipeit_fri, _snipeit_sat, _snipeit_sun
FROM assets
INNER JOIN models on models.id = model_id
INNER JOIN users on users.id = assigned_to
WHERE assigned_to IS NOT NULL AND _snipeit_epc IS NOT NULL"

items = []

rs.each_hash do |row|
	item = Hash.new
	item["action"] = "create"

	data = Hash.new
	data["id"] = row["id"]
	data["model"] = row["name"]
	data["epc"] = row["_snipeit_epc"] 
	data["assigned_to"] = row["first_name"] + ' ' + row["last_name"]

	policy = Hash.new
	policy["mon"] = row["_snipeit_mon"]
	policy["tue"] = row["_snipeit_tue"]
	policy["wed"] = row["_snipeit_wed"]
	policy["thu"] = row["_snipeit_thu"]
	policy["fri"] = row["_snipeit_fri"]
	policy["sat"] = row["_snipeit_sat"]
	policy["sun"] = row["_snipeit_sun"]
	data["policy"] = policy
	item["data"] = data

	items << item
end

data = Hash.new
data["CheckoutList"] = items
puts  data.to_json

rescue Mysql::Error => e
	puts "Caught Error" . e.inspect

ensure
	mydb.close if mydb
end








