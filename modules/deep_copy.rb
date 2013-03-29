class Array
	def deep_copy
		map {|x| x.deep_copy}
	end
end

class Object
	def deep_copy
		dup
	end
end

class NilClass
	def deep_copy
		nil
	end
end

class Numeric
	def deep_copy
		self
	end
end

class Symbol
	def deep_copy
		self
	end
end
class TrueClass
	def deep_copy
		self
	end
end
class FalseClass
	def deep_copy
		self
	end
end
