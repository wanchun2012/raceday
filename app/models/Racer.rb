class Racer
	include ActiveModel::Model

	attr_accessor :id, :number, :first_name, :last_name, :gender, :group, :secs

	def to_s
		"#{@id}: #{@number}: #{@first_name}: #{@last_name}: #{@gender}: #{@group}: #{@secs}"
	end

	# initialize from both a Mongo and Web hash
	def initialize(params={})
		@id = params[:_id].nil? ? paramsp[:id] : params[:_id]
		@number = params[:number]
		@first_name = params[:first_name]
		@last_name = params[:last_name]
		@gender = params[:gender]
		@group = params[:group]
		@secs = params[:secs]
	end

	# tell Rails whether this instance is persisted
  	def persisted?
    	!@id.nil?
  	end
  	
  	def created_at
    	nil
  	end

  	def updated_at
    	nil
  	end

	# convenience method for access to client in console
	def self.mongo_client
		Mongoid::Clients.default
	end

	# convenience method for access to Racer collection
	def self.collection
		self.mongo_client['racers']
	end

	# accept an optional prototype, optional sort, optional skip, and optional limit. 
	# The default for the prototype is to “match all” 
	# – which means you must provide it a document that matches all records. 
	# The default for sort must be by number ascending. 
	# The default for skip must be 0 and the default for limit must be nil.
	# find all racers that match the given prototype
	# sort them by the given hash criteria
	# skip the specified number of documents
	# limit the number of documents returned if limit is specified
	# return the result
	def self.all(prototype={}, sort={:number=>1}, skip=0, limit=nil)
		collecton.find.projection({_id:true, number:true, first_name:true, last_name:true, gender:true, group:true, secs: true})
	end
end
	