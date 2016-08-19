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
	dots =
		"type": "FeatureCollection",
		"features": []		


	max_value = 0
	max_dot_value = 0

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
			step: 0
		}

		#create dots (ends of lines)
		dots.features.push {
			"type": "Feature",
			"geometry": {
				"type": "Point",
				coordinates: flow_data.origin.slice(0),
			},
			dot_value: -flow_data.value,
			"size": 0
		}

		dots.features.push {
			"type": "Feature",
			"geometry": {
				"type": "Point",
				coordinates: flow_data.destination.slice(0),
			}
			dot_value: +flow_data.value,
			"size": 0
		}

	# normalize flows
	for point_f in points.features
		point_f.on_flow.normalized_value = Math.abs(point_f.on_flow.value / max_value) * normal_spread
		point_f.on_flow.steps_to_spawn = kspawn * 1 / point_f.on_flow.normalized_value 


	#sum and remove identical dots, find absolute maximum dot value
	`
	var i = dots.features.length
	while (i--){
		if ( Math.abs(dots.features[i].dot_value) > Math.abs(max_dot_value) ) { max_dot_value = Math.abs(dots.features[i].dot_value) }   
    for (j = 0; j < i; j++) {
    	if ((dots.features[j].geometry.coordinates[0] == dots.features[i].geometry.coordinates[0])&&(dots.features[j].geometry.coordinates[1] == dots.features[i].geometry.coordinates[1]))	{
    		dots.features[j].dot_value += dots.features[i].dot_value;
    		dots.features.splice( i, 1);
    		break;
    	}
    }
	}

	`

	# set dot size in percent according to normalized dot_value

	for dot_f in dots.features
		switch true
			when Math.abs( dot_f.dot_value / max_dot_value ) < 0.1
				dot_f.size = 0
			when Math.abs( dot_f.dot_value / max_dot_value ) < 0.2
				dot_f.size = 10
			when Math.abs( dot_f.dot_value / max_dot_value ) < 0.3
				dot_f.size = 20
			when Math.abs( dot_f.dot_value / max_dot_value ) < 0.4
				dot_f.size = 30
			when Math.abs( dot_f.dot_value / max_dot_value ) < 0.5
				dot_f.size = 40
			when Math.abs( dot_f.dot_value / max_dot_value ) < 0.6
				dot_f.size = 50
			when Math.abs( dot_f.dot_value / max_dot_value ) < 0.7
				dot_f.size = 60
			when Math.abs( dot_f.dot_value / max_dot_value ) < 0.8
				dot_f.size = 70
			when Math.abs( dot_f.dot_value / max_dot_value ) < 0.9
				dot_f.size = 80
			when Math.abs( dot_f.dot_value / max_dot_value ) < 1
				dot_f.size = 90
			when Math.abs( dot_f.dot_value / max_dot_value ) == 1
				dot_f.size = 100



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
			"data": points,
			"cluster": false
		});

		map.addSource('dots', {
			"type": "geojson",
			"data": dots,
			"cluster": false
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
					"icon-image": "bank-11",
					"icon-allow-overlap": true					
			}
		});

		map.addLayer({
			"id": "dots_layer",
			"source": "dots",
			"type": "circle",
			"paint": {
					"circle-radius": {
						"property": "size",
						"stops":[
							[ 0, 4],
							[10, 6],
							[20, 8],
							[30, 10],
							[40, 12],
							[50, 14],
							[60, 16],
							[70, 18],
							[80, 20],
							[90, 22],
							[100, 24],
						]
					},
					"circle-color": {
						"property": "size",
						"stops":[
							[ 0, "#007cbf"],
							[10, "#107cbf"],
							[20, "#207cbf"],
							[30, "#307cbf"],
							[40, "#407cbf"],
							[50, "#507cbf"],
							[60, "#607cbf"],
							[70, "#707cbf"],
							[80, "#807cbf"],
							[90, "#907cbf"],
							[100, "#A07cbf"],
						]
					}
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



