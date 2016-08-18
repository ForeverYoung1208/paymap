#$(document).ready ->
	# // Washington DC
destination = [-77.032, 38.913]

$.get('/transferts.json', {dataType: 'json'}, (data)->
	flows_data = data

	# //Kyiv
	# 50°27′N 	30°31′E
	kyiv = [30.445, 50.5166]

	# 1/(how many steps from origin to destination)
	# (smoothness of animation) kdelta = 0.005  500 steps(frames) from origin to destination
	kdelta = 0.002

	# 1/(how often points will spawm) ( kspawn = 500  will spawm point every 500 frame for flow value = 1) 
	kspawn = 500

	# spread of flow values from 0 to normal_spread
	normal_spread = 20


	flows = 
		"type": "FeatureCollection",
		"features": []
	points =
		"type": "FeatureCollection",
		"features": []		


	max_value = 0

	# create points and flows for every flow_data

	for flow_data in flows_data

		# prepare origins and destinations using value sign
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

		# calculate d_x and d_y
		d_x = kdelta*( d[0] - o[0] )
		d_y = kdelta*( d[1] - o[1] )

		#create flow (line)
		count_flows = flows.features.push {
			"type": "Feature",
			"geometry": {
				"type": "LineString",
				"coordinates": [ flow_data.origin, flow_data.destination ]
			}
			value: flow_data.value ,			
			normalized_value: 0,
			steps_to_spawn: 0,
			step_from_spawn: 0
		}

		max_value = Math.abs(flow_data.value) if Math.abs(flow_data.value) > Math.abs(max_value)

		#create point (money sign)
		points.features.push {
			"type": "Feature",
			"geometry": {
				"type": "Point",
				coordinates: o,
			}
			on_flow: flows.features[count_flows-1],
			origin: o,
			destination: d,
			delta_x: d_x,
			delta_y: d_y,
			step: 0,
		}

	# normalize flows
	for point_f in points.features
		point_f.on_flow.normalized_value = Math.abs(point_f.on_flow.value / max_value) * normal_spread
		point_f.on_flow.steps_to_spawn = kspawn * 1 / point_f.on_flow.normalized_value 




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
			if flow_f.step_from_spawn >= flow_f.steps_to_spawn
				switch true
					when ( +flow_f.value > 0 )
						o = flow_f.geometry.coordinates[0].slice(0)
						d = flow_f.geometry.coordinates[1].slice(0)
					when ( +flow_f.value < 0 )
						o = flow_f.geometry.coordinates[1].slice(0)
						d = flow_f.geometry.coordinates[0].slice(0)
					else
						o = 0
						d = 0

				d_x = kdelta*( d[0] - o[0] )
				d_y = kdelta*( d[1] - o[1] )


				points.features.push {
					"type": "Feature",
					"geometry": {
						"type": "Point",
						coordinates: o,
					}
					on_flow: flow_f,
					origin: o,
					destination: d,
					delta_x: d_x,
					delta_y: d_y,
					step: 0,
				}
				flow_f.step_from_spawn = 0
			else
				flow_f.step_from_spawn += 1



				

	mapboxgl.accessToken = 'pk.eyJ1IjoiZm9yZXZlcnlvdW5nMTIwOCIsImEiOiJjaXJodnd1bHYwMDRjajFtNWU5aDZrMDk1In0.4Q1TtVizWiiiu6oUPL2mhw'
	map = new mapboxgl.Map({
		#// container id
		container: 'map',
		#// style location
		style: 'mapbox://styles/mapbox/streets-v9'	    
		#// starting position
		center: kyiv,
		zoom: 7
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
		end = 5000
		animate();
	);
)



