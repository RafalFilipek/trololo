# What can I say. Simple service with 2 methods.
# `Success` callback sets `$rootScope.isLogged`
# to check if user is logged.

app.factory('gitlab', ($http, $rootScope)->
	apiUrl = '/api/v1/'
	{
		'get': (path, params = {})->
			paramsString = (key + '=' + val for key, val of params).join('&')
			$http.get(apiUrl + path + '?' + paramsString).success((response)->
				$rootScope.isLogged = response.authorized
			)
		'post': (path, data)->
			$http.post(apiUrl + path, data).success((response)->
				$rootScope.isLogged = response.authorized
			)
	}
)
