app.filter('formatDate', ->
	(date)-> new Date(date).getTime()
)
