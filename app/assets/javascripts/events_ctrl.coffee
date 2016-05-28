angular.module('classy-highlights').controller 'EventsCtrl', ['$scope', '$http', ($scope, $http) ->
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
]
