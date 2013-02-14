app = angular.module('app', ['ngResource', 'ngCookies', 'ui'])
	.config(($routeProvider, $locationProvider)->

		# Routing

		$routeProvider
			.when('/', {
				'controller': 'EntryPointCtrl'
			})
			.when('/login', {
				'templateUrl': '/static/templates/login.html'
				'controller': 'LoginCtrl'
			})
			.when('/home', {
				'templateUrl': '/static/templates/home.html'
				'controller': 'HomeCtrl'
			})
	).run(($rootScope, $location)->

		# I'm too lazy to check is user is logged by myself
		# How it works? See `services.coffee`.

		$rootScope.$watch('isLogged', ->
			if angular.isDefined($rootScope.isLogged)
				currentPath = $location.path()
				path = if $rootScope.isLogged
					if currentPath is '/login' then '/home' else currentPath
				else
					'/login'
				$location.path(path)
		)
	)


