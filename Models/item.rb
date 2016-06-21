require "json"
require "timeRestriction"

class Item
	include Logging

	attr_reader :id, :model, :epc, :policy, :assigned_to

	def initialize(id, model, epc, policy, assigned_to)
		@id = id
		@model = model
		@epc = epc
		@policy = nil
		@assigned_to = assigned_to
		self.parse(policy)
	end

	def parse (policy)
		unless policy.nil? || policy.empty?
			@policy = Hash.new

			JSON.parse(policy).each do |key, val|
				@policy[key] = TimeRestriction.new(val)
			end
		end
		#logger.debug {"Item TimeRestriction #{@policy.inspect}"}
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