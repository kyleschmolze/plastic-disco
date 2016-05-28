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

  $scope.tagWithSelectedEvent = ->
    $http.post "/videos/#{$scope.video_id}/tag", { event_id: $scope.selectedEvent.id, seconds_into_clip: $scope.secondsIntoClip, minutes_into_clip: $scope.minutesIntoClip }
    .success (data) ->
      alert "Success! Refresh the page to review"
]
