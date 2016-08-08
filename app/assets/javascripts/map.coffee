

# // Washington DC
destination = [-77.032, 38.913]

flows = [
	{
		origin: [30.445, 50.5166],
		destination: [30.145, 50.1166],
		value : 0.5,
		nаme : 'Name1'
	},

	{
		origin: [30.445, 50.5166],
		destination: [30.945, 50.9166],
		value : 0.2,
		nаme : 'Name2'
	},

	{
		origin: [30.445, 50.5166],
		destination: [30.445, 50.8566],
		value : -0.2,
		nаme : 'Dnipro'
	},
]

# flows = $.get('/transferts.json', (data)->
# 	return data
# )


# //Kyiv
# 50°27′N 	30°31′E
origin = [30.445, 50.5166]
my_features = []

for flow in flows
	my_features.push {
		"type": "Feature",
		"geometry": {
			"type": "LineString",
			"coordinates": [
					flow.origin,
					flow.destination
			]
		}
	}

route = {
	"type": "FeatureCollection",
	"features": my_features
};

point = {
	"type": "FeatureCollection",
	"features": [{
			"type": "Feature",
			"geometry": {
					"type": "Point",
					"coordinates": origin
			}
	}]
};





$(document).ready ->
	mapboxgl.accessToken = 'pk.eyJ1IjoiZm9yZXZlcnlvdW5nMTIwOCIsImEiOiJjaXJodnd1bHYwMDRjajFtNWU5aDZrMDk1In0.4Q1TtVizWiiiu6oUPL2mhw'
	map = new mapboxgl.Map({
		#// container id
		container: 'map',
		#// style location
		style: 'mapbox://styles/mapbox/streets-v9'	    
		#// starting position
		center: origin,
		zoom: 4
	})

	map.on('load', ->
		map.addSource('route', {
				"type": "geojson",
				"data": route
		});
		
		map.addSource('point', {
				"type": "geojson",
				"data": point
		});


		map.addLayer({
			"id": "route",
			"source": "route",
			"type": "line",
			"paint": {
					"line-width": 2,
					"line-color": "#007cbf"
			}
		});
		map.addLayer({
			"id": "point",
			"source": "point",
			"type": "symbol",
			"layout": {
					"icon-image": "bank-11"
			}
		});
	)
