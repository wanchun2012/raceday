module RacersHelper
	# accept a single input argument
	# if the type of the input argument is a Racer, 
	# simply return the instance unmodified. Else attempt to
	# instantiate a Racer from the input argument and return the result.
	def toRacer(value)
		return value.is_a?(Racer) ? value : Racer.new(value) 
	end
end
