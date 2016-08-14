#$(document).ready ->
	# // Washington DC
destination = [-77.032, 38.913]

$.get('/transferts.json', {dataType: 'json'}, (data)->
	flows_data = data

	# //Kyiv
	# 50°27′N 	30°31′E
	kyiv = [30.445, 50.5166]

	# 1/speed
	kdelta = 0.01

	flows = 
		"type": "FeatureCollection",
		"features": []
	points =
		"type": "FeatureCollection",
		"features": []		


	max_value = 0

	# create points and flows for every flow_data

	for flow_data in flows_data
		switch true
			when ( +flow_data.value > 0 )
				o = flow_data.origin.slice(0)
				d = flow_data.destination.slice(0)
			when ( +flow_data.value < 0 )
				o = flow_data.destination.slice(0)
				d = flow_data.origin.slice(0)
			else
				o = 0
				d = 0


		cf = flows.features.push {
			"type": "Feature",
			"geometry": {
				"type": "LineString",
				"coordinates": [ o, d ]
			}
			value: flow_data.value ,			
			normalized_value: 0,
			step_to_spawn: 0,
			step: 0
		}

		max_value = Math.abs(flow_data.value) if Math.abs(flow_data.value) > Math.abs(max_value)

		points.features.push {
			"type": "Feature",
			"geometry": {
				"type": "Point",
				coordinates: o,
			}
			on_flow: flows.features[cf-1],
			origin: o,
			destination: d,
			delta_x: 0,
			delta_y: 0,
			step: 0,
		}

	# normalize flows
	# calculate deltas in points
	for point_f in points.features
		point_f.on_flow.normalized_value = (point_f.on_flow.value / max_value) * 100
		point_f.delta_x = kdelta*( point_f.destination[0] - point_f.origin[0] )
		point_f.delta_y = kdelta*( point_f.destination[1] - point_f.origin[1] )


	# calc new positions for points
	`
  calc_points_new_position = function(points_f) {
		var i = points_f.length
		while (i--){
			if (points_f[i].step <= 1 / kdelta) {
					points_f[i].geometry.coordinates[0] += points_f[i].delta_x;
					points_f[i].geometry.coordinates[1] += points_f[i].delta_y;
					points_f[i].step += 1;
				} else {
					points_f.splice( i, 1);
				}
		}
	}
	`

	# function to check the necessity on spawning of new points

	check_for_spawn = (flows_f) ->
		for flow_f in flows_f
			true

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
			calc_points_new_position( points.features )
			check_for_spawn( flows.features )
			map.getSource('points').setData( points );
			if (counter < end) {
				requestAnimationFrame(animate) 
			}
		}
		`			


		counter = 0;
		end = 1000
		animate();
	);
)



