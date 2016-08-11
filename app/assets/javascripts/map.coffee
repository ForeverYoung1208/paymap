#$(document).ready ->
	# // Washington DC
destination = [-77.032, 38.913]

$.get('/transferts.json', {dataType: 'json'}, (data)->
	flows_data = data

	# //Kyiv
	# 50°27′N 	30°31′E
	kyiv = [30.445, 50.5166]

	flows = 
		"type": "FeatureCollection",
		"features": []
	points =
		"type": "FeatureCollection",
		"features": []		


	max_dist = 0
	max_value = 0

	# create points and flows

	for flow_data in flows_data
		x = flow_data.origin.slice(0)
		y = flow_data.destination.slice(0)
		flows.features.push {
			"type": "Feature",
			"geometry": {
				"type": "LineString",
				"coordinates": [ x, y ]
			}
		}

		dist = (flow_data.destination[0]-flow_data.origin[0]) + (flow_data.destination[0]-flow_data.origin[0])
		max_dist = dist if dist > max_dist
		max_value = flow_data.value if flow_data.value > max_value
		f_o = flow_data.origin.slice(0)

		points.features.push {
			"type": "Feature",
			"geometry": {
				"type": "Point",
				coordinates: f_o,
				on_flow: flow_data,
				dist: dist,
				delta_x: 0,
				delta_y: 0
			}
		}

	# normalize points
	#
	#
	#



	calc_new_point_position = (points)->
		for point in points
			point.geometry.coordinates[0] += point.geometry.delta_x
			point.geometry.coordinates[1] += point.geometry.delta_y
		return true




	mapboxgl.accessToken = 'pk.eyJ1IjoiZm9yZXZlcnlvdW5nMTIwOCIsImEiOiJjaXJodnd1bHYwMDRjajFtNWU5aDZrMDk1In0.4Q1TtVizWiiiu6oUPL2mhw'
	map = new mapboxgl.Map({
		#// container id
		container: 'map',
		#// style location
		style: 'mapbox://styles/mapbox/streets-v9'	    
		#// starting position
		center: kyiv,
		zoom: 5
	})

	map.on('load', ->
		map.addSource('routes', {
				"type": "geojson",
				"data": flows
		});
		
		map.addSource('points', {
			"type": "geojson",
			"data": points
		});


		map.addLayer({
			"id": "routes_layer",
			"source": "routes",
			"type": "line",
			"paint": {
					"line-width": 2,
					"line-color": "#007cbf"
			}
		});
		map.addLayer({
			"id": "points_layer",
			"source": "points",
			"type": "symbol",
			"layout": {
					"icon-image": "bank-11"
			}
		});


		`		
		function animate(){
			counter = counter + 1
			calc_new_point_position( points.features )
			map.getSource('points').setData( points );
			if (counter < end) {
				requestAnimationFrame(animate) 
			}
		}
		`			


		counter = 0;
		end = 100
		animate();
	);
)



