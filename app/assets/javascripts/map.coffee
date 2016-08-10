#$(document).ready ->
	# // Washington DC
destination = [-77.032, 38.913]

$.get('/transferts.json', {dataType: 'json'}, (data)->
	flows = data[145...160]

	# //Kyiv
	# 50°27′N 	30°31′E
	kyiv = [30.445, 50.5166]

	flows_as_data = 
		"type": "FeatureCollection",
		"features": []
	points_as_data =
		"type": "FeatureCollection",
		"features": []		

	for flow in flows
		flows_as_data.features.push {
			"type": "Feature",
			"geometry": {
				"type": "LineString",
				"coordinates": [
						flow.origin,
						flow.destination
				]
			}
		}

		d_x = (flow.origin[0]-flow.destination[0])/(flow.value)
		d_y = (flow.origin[1]-flow.destination[1])/(flow.value)

		points_as_data.features.push {
			"type": "Feature",
			"geometry": {
				"type": "Point",
				coordinates: flow.origin,
				on_flow: flow,
				delta_x: d_x,
				delta_y: d_y
			}
		}

	# calc_new_point_position = (padfs)->
	# 	for padf in padfs
	# 		delta_x=(padf.geometry.on_flow.origin[0]-padf.geometry.on_flow.destination[0])/(padf.geometry.on_flow.value*10)
	# 		delta_y=(padf.geometry.on_flow.origin[1]-padf.geometry.on_flow.destination[1])/(padf.geometry.on_flow.value*10)

	# 		padf.geometry.coordinates[0] += delta_x
	# 		padf.geometry.coordinates[1] += delta_y

	calc_new_point_position = (padfs)->
		padf = padfs[0]
		padf.geometry.coordinates[0] += padf.geometry.delta_x
		padf.geometry.coordinates[1] += padf.geometry.delta_y




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
				"data": flows_as_data
		});
		
		map.addSource('points', {
			"type": "geojson",
			"data": points_as_data
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



		animate = (counter, end)->
			counter +=1
#			calc_new_point_position( points_as_data.features )

#			map.getSource('points').setData( points_as_data );

			requestAnimationFrame(animate(counter,end)) if counter < end


		counter = 0;
		animate(counter, 1000 );
	);
)



