require "json"
require "timeRestriction"

class Item
	include Logging

	attr_reader :id, :model, :epc, :policy

	def initialize(id, model, epc, policy)
		@id = id
		@model = model
		@epc = epc
		@policy = Hash.new
		#@policy = JSON.parse(policy)
		self.parse(JSON.parse(policy))
	end

	def parse (policy)
		unless policy.nil?
			policy.each do |key, val|
				@policy[key] = TimeRestriction.new(val)
			end
		else
			@policy = nil
		end
		#ogger.debug {"Item TimeRestriction #{@policy.inspect}"}
	end

	def isAllowed
		day = Date::ABBR_DAYNAMES[Date.today.wday]
		unless @policy.nil?
			@policy[day].isAllowed
		else
			true
		end
	end
end