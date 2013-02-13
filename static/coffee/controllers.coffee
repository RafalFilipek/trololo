EntryPointCtrl = ($scope, $location, $rootScope, gitlab)->
	gitlab.get({action:'check'}, (response)->
		$rootScope.isLogged = response.authorized
	)

LoginCtrl = ($scope, $location,  $cookies, $rootScope, gitlab)->
	$scope.invalidToken = false
	$scope.isChecking = false

	$scope.login = ->
		$scope.isChecking = true
		gitlab.get({
			action:'check',
			private_token: $scope.private_token
		}, (response)->
			$scope.isChecking = false
			if response.authorized
				$cookies.private_token = $scope.private_token
				$scope.invalidToken = false
				$rootScope.isLogged = true
			else
				$scope.invalidToken = true
		)

HomeCtrl = ($scope, $rootScope, gitlab)->
	$scope.user = false
	$scope.issues = {}
	currentDragged = undefined;

	$scope.setDraggable = (repr)->
		currentDragged = repr

	$scope.moveDragged = (type, index)->
		item = $scope.issues[currentDragged.type][currentDragged.index]
		$scope.issues[currentDragged.type].splice(currentDragged.index, 1)
		$scope.issues[type].splice(index, 0, item)

	gitlab.get({action:'user'}, (response)->
		$rootScope.isLogged = response.authorized
		$scope.user = response.data
	)
	gitlab.get({action:'projects'}, (response)->
		$rootScope.isLogged = response.authorized
		$scope.projects = response.data
		$scope.currentProject = $scope.projects[0].id
	)

	###
	Yep, test crap section.
	###
	setState = (issue)->
		issue.type = if _.contains(issue.labels, 'Performance')
			'todo'
		else if issue.labels.length is 0
			'todo'
		else if _.contains(issue.labels, 'feature')
			'wip'
		else 'done'


	$scope.$watch('currentProject', ->
		if $scope.currentProject
			gitlab.get({action:'projects/' + $scope.currentProject + '/issues'}, (response)->
				$scope.issues = _.groupBy(response.data, setState)
			)
	)
