app.factory('gitlab', ($resource)->
	new $resource('/api/v1/:action')
)
