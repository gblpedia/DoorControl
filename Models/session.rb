#append the current directory to the search path
$: << File.dirname(__FILE__)

require "sqlite3"

module Models

	class Session
		include Logging

		def initialize
			@client_id = nil
			begin
				#@db = SQLite3::Database.open File.join(File.dirname(__FILE__),"..","sqlite.db")
				@table = "session"
				logger.debug {"Session: Load Sqlite #{@db}" }
				
			rescue SQLite3::Exception => e
				logger.debug {"Exception #{e}" }
			end
		end

		def create(topic, client_id)
			begin
				@db = SQLite3::Database.open File.join(File.dirname(__FILE__),"..","sqlite.db")
				logger.debug {"Load Sqlite #{@db}" }
				@db.execute("INSERT INTO #{@table} (topic, client_id) VALUES (?,?)", [ topic, client_id ])
				logger.debug{"stored session : #{client_id} over #{topic}"}
				@db.close
				
			rescue SQLite3::Exception => e
				logger.debug {"Exception #{e}" }
			end
			
		end

		def getClientId(topic)
			begin
				@db = SQLite3::Database.open File.join(File.dirname(__FILE__),"..","sqlite.db")
				logger.debug {"Load Sqlite #{@db}" }
				
				@db.execute("SELECT client_id FROM #{@table} WHERE topic = ? ", [topic]) do |row|
					@client_id = row[0]
				end
				logger.debug{"restored session: #{@client_id} over #{topic}"}
				@db.close

				return @client_id
				
			rescue SQLite3::Exception => e
				logger.debug {"Exception #{e}" }
			end
		end
	end
end
