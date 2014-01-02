# Test class for DBScan

require './db_scan.rb'

class Test
  include DbScan
  def self.test
    points = [
      # cluster 1
      [40.027535, 116.430958],[40.0365549, 116.4237565],[39.901588, 116.639648],[40.022241, 116.417642],[40.012861, 116.416171],[39.905643, 116.638633],
      # cluster 2
    [39.9083369, 116.6416102],[39.906871, 116.640869],[40.0360064, 116.4241946],[39.99533, 116.417854]
    ]

    puts dbscan(points, epsilon=0.05, min_pts=2).inspect
  end
end

Test.test
