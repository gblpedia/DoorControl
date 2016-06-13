#append the current directory to the search path
$: << File.dirname(__FILE__)

require "item"
require "sqlite3"

module Models

	class Checkout
		include Logging

		@@items = Hash.new

		def initialize
			begin
				@db = SQLite3::Database.open File.join(File.dirname(__FILE__),"..","sqlite.db")
				@table = "checkout"
				
				self.load

			rescue SQLite3::Exception => e
				logger.debug {"Exception #{e}" }
			end
		end

		def self.items
			@@items
		end

		def load
			@db.execute("SELECT * FROM checkout") do |row|
				item = Item.new(row[0], row[1], row[2], row[3])
				@@items[item.epc] = item
			end
			logger.debug{"Load items: #{@@items.inspect}"}
		end

		def create(data)
			logger.debug {"create: #{data.inspect}"}
			id = data["id"]
			model = data["model"]
			epc = data["epc"]
			policy = data["policy"].to_json
			
			@db.execute("INSERT INTO #{@table} (id, model, epc, policy) VALUES (?,?,?,?)", [ id, model, epc , policy ])

			item = Item.new(id, model, epc, policy)
			@@items[epc] = item
			logger.debug{"whitelist : #{@@items.inspect}"}
		end

		# consider to remove the item, then create the item rather than update it.
		def update(id, epc)
			#@db.execute("UPDATE #{@table} SET epc = ? WHERE id = ?", [epc, id])
		end

		def delete(data)
			id = data["id"]
			@db.execute("DELETE FROM #{@table} WHERE id = ? ", [id])
			@@items.delete_if {|_,val| val == id}
			logger.debug {"whitelist: #{@@items.inspect}"}
		end

		def deleteByEpc(data)
			epc = data["epc"]
			@db.execute("DELETE FROM #{@table} WHERE epc = ? ", [epc])
			@@items.delete(epc)
			logger.debug {"whitelist: #{@@items.inspect}"}
		end

		def close
			@db.close
		end
	end
end
