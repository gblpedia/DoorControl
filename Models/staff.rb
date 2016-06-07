#append the current directory to the search path
$: << File.dirname(__FILE__)


require "sqlite3"

module Models

	class Staff

		def initialize
			@db = SQLite3::Database.open "sqlite.db"
			@table = "staff"
		end

		def create(id, epc)
			@db.execute("INSERT INTO #{@table} (id, card_epc) VALUES (?,?)", [id, epc])
		end

		def update(id, epc)
			@db.execute("UPDATE #{@table} SET card_epc = ? WHERE id = ?", [epc, id])
			
		end

		def delete(id)
			@db.execute("DELETE FROM #{@table} WHERE id = ? ", [id])
		end

		def close
			@db.close
		end
	end
end
