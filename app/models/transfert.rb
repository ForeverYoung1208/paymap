class Transfert < ActiveRecord::Base

	def origin
		# //Kyiv
		# 50°27′N 	30°31′E

		[30.445, 50.5166]

	end

	def destination
		# //Kyiv
		# 50°27′N 	30°31′E
		origin = [30.445, 50.5166]
		self.coord_x = 0 if !self.coord_x
		self.coord_y = 0 if !self.coord_y

		[ self.coord_x+self.origin[0] , self.coord_y+self.origin[1]]
	end

	def value
		self.baz_dot = 0 if !self.baz_dot
		self.rev_dot = 0 if !self.rev_dot

		result = self.baz_dot - self.rev_dot
	end
end
