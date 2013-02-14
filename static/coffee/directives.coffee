# No magic.
# Simplest version of AngularJS directive
# and basic usage of jQueryUI Sortable.

app.directive('sortable', ->
	{
		'link': (scope, element, attrs)->
			$(element).sortable({
				'connectWith': '.column'
				'appendTo': 'body'
				'revert': 0
				'helper': 'clone'
				'start': (e, ui)->
					ui.helper.data('type', scope.type)
					index = $(ui.item).index()
					scope.setDraggable({
						'index': $(ui.item).index()
						'type': attrs.type
					})
				'receive': (e, ui)->
					scope.$apply(scope.moveDragged(attrs.type,  ui.item.index()))
			}).disableSelection()
	}
)

