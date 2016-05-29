angular.module('classy-highlights').controller 'EventsCtrl', ['$scope', '$http', ($scope, $http) ->
  $scope.init = (video_id) ->
    $scope.video_id = video_id
    $http.get("/videos/#{video_id}").success (d) -> $scope.video = d

  $scope.loadEvents = ->
    params = { query: $scope.query }
    if $scope.requireVideo
      params.require_video = true
    $http.get '/events/search.json', params: params
    .success (data) ->
      console.log data
      $scope.events = data

  $scope.loadMore = ->
    params = { query: $scope.query, offset: $scope.events.length }
    if $scope.requireVideo
      params.require_video = true
    $http.get '/events/search.json', params: params
    .success (data) ->
      $scope.events = $scope.events.concat data

  $scope.typing = _.debounce $scope.loadEvents, 200

  $scope.loadEvents()

  $scope.seekTo = (event) ->
    loc = event.starts_at_since_epoch - video.starts_at_since_epoch
    window.seek loc


  # This stuff only happens on videos#show

  $scope.select = (event) ->
    $scope.selectedEvent = event

  $scope.clearSelection = ->
    $scope.selectedEvent = null

  $scope.alignWithoutEvent = ->
    $http.put "/videos/#{$scope.video_id}.json", video: { aligned: true }
    .success (data) ->
      alert "Success! Refreshing the page now for review..."
      location.reload()
    .error ->
      alert "Failure!"

  $scope.alignWithSelectedEvent = ->
    event.starts_at
    $http.post "/videos/#{$scope.video_id}/align_to_event.json", { event_id: $scope.selectedEvent.id, seconds_into_clip: $scope.secondsIntoClip, minutes_into_clip: $scope.minutesIntoClip }
    .success (data) ->
      alert "Success! Refreshing the page now for review..."
      location.reload()
    .error (data) ->
      alert "Failure! Did you input seconds and minutes?"
]
