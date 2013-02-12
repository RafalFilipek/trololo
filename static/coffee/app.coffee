app = angular.module('app', ['ngResource', 'ngCookies'])
	.config(($routeProvider, $locationProvider)->
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
		$rootScope.$watch('isLogged', ->
			if angular.isDefined($rootScope.isLogged)
				path = if $rootScope.isLogged then '/home' else '/login'
				$location.path(path)
		)
	)


