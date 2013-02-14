# Le filter to format date from GitLab API.

app
.filter('formatDate', ->
	(date)-> new Date(date).getTime()
)
.filter('markdown', ->
	(text)-> marked(text)
)
