class Transfert < ActiveRecord::Base

	def origin

		# Define the same origin for all transferts
		# //Kyiv
		# 50°27′N 	30°31′E
		[30.445, 50.5166]
	end

	def destination

		# Get destination coordinates (random (1) for development purposes)
		# And strech them over the map to get nice view for development purposes
		self.coord_x = 0 if !self.coord_x
		self.coord_y = 0 if !self.coord_y
		[ (self.coord_x-0.5)*10 + origin[0] , (self.coord_y-0.5)*6 + origin[1] ]
		
	end

	def value
		self.baz_dot = 0 if !self.baz_dot
		self.rev_dot = 0 if !self.rev_dot

		result = self.baz_dot - self.rev_dot
	end
end
