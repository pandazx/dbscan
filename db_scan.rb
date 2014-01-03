####################################################
# shiguodong, June 2011
# References:
#   1. see also wikipedia entry (this implementation is similar to
#      their pseudo code): http://en.wikipedia.org/wiki/DBSCAN
####################################################
module DbScan
	def self.included(base)
		base.extend(ClassMethods)
	end

	module ClassMethods
		def dbscan(points, epsilon=0.05, min_pts=2)
			@points,@epsilon,@min_pts = points,epsilon,min_pts
			init_point
			_dbscan
		end

		# convert @points to Point object array
		def init_point
			return @points if (!@points.is_a? Array) or (@points.size<2)
			@new_points = []
			@points.each{|point| @new_points.push(Point.new(point))}
		end

		# make clusters from @new_points
		def _dbscan
			clusters = {}     
			clusters[-1] = []
			current_cluster = -1

			@new_points.each{|point|
				unless point.visited
					# unclassified point
					point.visited = true
					neighbours = immediate_neighbours(point)
					if neighbours.size >= @min_pts
						# make a new cluster
						current_cluster += 1
						point.cluster = current_cluster                
						cluster = [point,]
						cluster.push(add_connected(neighbours,current_cluster))
						clusters[current_cluster] = cluster.flatten
					else
						# this point is not a cluster
						# because this cluster size is below min_pts
						clusters[-1].push(point)
					end
				end
			}
			return as_hash(clusters)
		end

		# make a hash from clusters. key is cluster_id. value is point(lat, lon)
		def as_hash(clusters)
			clusters.inject({}){|hash, (key,value)|
				hash[key]=value.flatten.map(&:items) unless value.flatten.empty?
				hash
			}
		end

		# make point array of neighbours. it is not include parameter's point
		def immediate_neighbours(point)
			neighbours = []
			@new_points.each{|p|
				next if p.items == point.items
				d = distance(point.items,p.items)
				neighbours.push(p) if d < @epsilon
			}
			neighbours
		end

		# euclid distance
		def distance(p1,p2)
			raise "Error" if p1.size != p2.size
			sum = (0...p1.size).inject(0){|sum,i| sum+=(p1[i]-p2[i])**2}
			Math.sqrt(sum)
		end

		# make points array from neighbours point and set current_cluster id
		def add_connected(neighbours,current_cluster)
			cluster_points = []
			neighbours.each do |point|
				unless point.visited
					point.visited = true 
					new_points = immediate_neighbours(point)
					if new_points.size >= @min_pts
						new_points.each do |p|
							neighbours.push(p) unless (neighbours.include? p)
						end
					end
				end

				unless point.cluster
					# add point to current cluster
					cluster_points.push(point)
					point.cluster = current_cluster
				end
			end
			return cluster_points
		end

	end
end

class Point
	attr_accessor :items,:cluster,:visited
	def initialize(point)
		# lat, lon
		self.items = point
		# cluster id
		self.cluster = nil
		# classify flag
		self.visited = false
	end
end
