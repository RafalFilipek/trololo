
# Nothing to do here. GitLab service will notify application
# if user is logged or not.

EntryPointCtrl = ($scope, $location, $rootScope, gitlab)->
	gitlab.get('check')

# All we have to do in LoginCtrl is grab user token and
# execute `check` request. `success` callback is just a
# dump function to show or hide some messages.

LoginCtrl = ($scope, $location,  $cookies, $rootScope, gitlab)->
	$scope.invalidToken = false
	$scope.isChecking = false

	$scope.login = ->
		$scope.isChecking = true
		gitlab.get('check', {'private_token': $scope.private_token})
		.success((response)->
			$scope.isChecking = false
			if response.authorized
				$cookies.private_token = $scope.private_token
				$scope.invalidToken = false
			else
				$scope.invalidToken = true
		)

# Big one.

HomeCtrl = ($scope, $rootScope, gitlab)->

	# Some defaults.

	$scope.user = false
	$scope.current = {
		'project': undefined
		'milestone': undefined
	}
	$scope.projects = undefined
	$scope.milestones = undefined
	$scope.issues = undefined
	@currentDragged = undefined

	# Two function used by `sortable` directive.
	# `currentDragged` is just a simple object
	# with two keys: type, key.
	#
	# In `moveDragged` function I'm using `splice`
	# method like a boss to move issue.

	$scope.setDraggable = (repr)=>
		@currentDragged = repr

	$scope.moveDragged = (type, index)=>
		item = $scope.issues[@currentDragged.type][@currentDragged.index]
		$scope.issues[@currentDragged.type].splice(@currentDragged.index, 1)
		$scope.issues[type].splice(index, 0, item)

	# First we need some informations about user
	# Mainly to display "Hello" message.

	gitlab.get('user').success((response)->
		$scope.user = response.data
	)

	# Projects are quite important. Just another
	# gitlab GET request.

	gitlab.get('projects').success((response)->
		$scope.projects = response.data
	)

	# Simple function to define issue state.
	# It's called every time new issues are
	# greabbed from server.

	setState = (issue)->
		states = ['todo', 'wip', 'done', 'trash']
		labels = issue.labels
		for state in states
			return state if _.contains(labels, state)
		return 'todo'

	# Another silly function to filter issues by milestone.

	$scope.filterByMilestone = (issue)->
		currentMilestone = parseInt($scope.current.milestone, 10)
		if _.isNumber(currentMilestone) and not _.isNaN(currentMilestone)
			return (issue.milestone or {}).id is currentMilestone
		else
			return true

	# Every time user decide to change current project callback
	# function will grab milestones and issues.

	$scope.$watch('current.project', ->
		if $scope.current.project
			$scope.current.milestones = undefined
			gitlab.get('projects/' + $scope.current.project + '/milestones').success((response)->
				$scope.milestones = response.data
				gitlab.get('projects/' + $scope.current.project + '/issues').success((response)->
					$scope.issues = _.extend(
						{ 'todo': [], 'wip': [], 'done': [], 'trash': [] },
						_.groupBy(response.data, setState)
					)
				)
			)
	)
