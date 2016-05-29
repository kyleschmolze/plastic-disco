angular.module('classy-highlights').controller 'EventsCtrl', ['$scope', '$http', ($scope, $http) ->
  $scope.init = (video_id) ->
    $scope.video_id = video_id

  $scope.loadEvents = ->
    $http.get '/events/search.json', params: { query: $scope.query }
    .success (data) ->
      console.log data
      $scope.events = data

  $scope.loadMore = ->
    $http.get '/events/search.json', params: { query: $scope.query, offset: $scope.events.length }
    .success (data) ->
      $scope.events = $scope.events.concat data

  $scope.typing = _.debounce $scope.loadEvents, 200

  $scope.loadEvents()

  # This stuff only happens on videos#show

  $scope.select = (event) ->
    $scope.selectedEvent = event

  $scope.clearSelection = ->
    $scope.selectedEvent = null

  $scope.alignWithoutEvent = ->
    $http.put "/videos/#{$scope.video_id}", video: { aligned: true }
    .success (data) ->
      alert "Success! Refreshing the page now for review..."
      location.reload()
    .error ->
      alert "Failure!"

  $scope.alignWithSelectedEvent = ->
    event.starts_at
    $http.post "/videos/#{$scope.video_id}/align_to_event", { event_id: $scope.selectedEvent.id, seconds_into_clip: $scope.secondsIntoClip, minutes_into_clip: $scope.minutesIntoClip }
    .success (data) ->
      alert "Success! Refreshing the page now for review..."
      location.reload()
    .error (data) ->
      alert "Failure! Did you input seconds and minutes?"
]
