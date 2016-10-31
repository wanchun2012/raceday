class Racer
	include ActiveModel::Model

	attr_accessor :id, :number, :first_name, :last_name, :gender, :group, :secs

	# initialize from both a Mongo and Web hash
	def initialize(params={})
		@id = params[:_id].nil? ? params[:id] : params[:_id].to_s
		@number = params[:number].to_i
		@first_name = params[:first_name]
		@last_name = params[:last_name]
		@gender = params[:gender]
		@group = params[:group]
		@secs = params[:secs].to_i
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
		Rails.logger.debug {'getting all racers, prototype=#{prototype}, sort=#{sort}, offset=#{skip}, limit=#{limit}'}

		result = collection.find(prototype)
			.projection({_id:true, number:true, first_name:true, last_name:true, gender:true, group:true, secs: true})
			.sort(sort)
			.skip(skip)
		result = result.limit(limit) if !limit.nil?
		return result
	end

	# accept a single id parameter that is either a string or BSON::ObjectId Note: it must be able to handle either format.
	# find the specific document with that _id
	# return the racer document represented by that id
	def self.find id
		Rails.logger.debug {"getting racer #{id}"}
		result = collection.find({'_id': BSON::ObjectId.from_string(id)}).first
		return result.nil? ? nil : Racer.new(result)
	end

	# take no arguments
	# insert the current state of the Racer instance into the database
	# obtain the inserted document _id from the result 
	# and assign the to_s value of the _id to the instance attribute @id
	def save
		Rails.logger.debug {"saving #{self}"}

		result = self.class.collection
					.insert_one(number:@number, first_name:@first_name, last_name:@last_name, gender:@gender, group:@group, secs: @secs)
		@id = result.inserted_id.to_s
	end

	# accept a hash as an input parameter
	# updates the state of the instance variables – except for @id. 
	# That never should change. • find the racer associated with the current @id instance variable in the database
	# update the racer with the supplied values – replacing all values
def update(params) 
	Rails.logger.debug {"updating #{self} with #{params}"}
	
    @number = params[:number].to_i
    @first_name = params[:first_name] 
    @last_name = params[:last_name]  
    @gender = params[:gender]
    @group = params[:group]
    @secs = params[:secs].to_i

    params.slice!(:number, :first_name, :last_name, :gender, :group, :secs)
    self.class.collection.find(:_id => BSON::ObjectId.from_string(@id))
                         .update_one(params)
  end

	# accept no arguments
	# find the racer associated with the current @number instance variable in the database 
	# remove that instance from the database
	def destroy
    	Rails.logger.debug {"destroying #{self}"}

    	self.class.collection
              .find(:_id => BSON::ObjectId.from_string(@id))
              .delete_one   
  	end  
end
	