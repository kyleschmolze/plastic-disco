angular.module('classy-highlights').controller 'VideoPlayerCtrl', ['$scope', '$http', '$element', ($scope, $http, $element) ->
  $scope.highlight = {}

  $scope.init = (video_id) ->
    $scope.video_id = video_id
    $http.get("/videos/#{video_id}.json").success (d) ->
      $scope.video = d
      console.log d

  $scope.createHighlight = ->
    $scope.highlight.video_id = $scope.video_id
    $scope.highlight.offset = ($scope.highlight.startMinutes||0)*60 + $scope.highlight.startSeconds
    $scope.highlight.duration = (($scope.highlight.endMinutes||0)*60 + $scope.highlight.endSeconds) - $scope.highlight.offset
    $http.post '/highlights.json', highlight: $scope.highlight
    .success (highlight) ->
      $scope.video.highlights or= []
      $scope.video.highlights.unshift highlight
      $scope.highlight = {}
      $scope.highlightFormVisible = false
    .error (data) ->
      alert "Failure! #{data.join('. ')}"

  $scope.jumpToHighlight = (highlight) ->
    console.log highlight
    iframe = $($element).find('iframe')
    src = iframe.attr 'src'
    without_params = src.replace /\?.*/, ''
    with_new_params = "#{without_params}?start=#{highlight.offset}&end=#{highlight.offset+highlight.duration}&autoplay=1&loop=1"
    iframe.attr 'src', with_new_params
    0 # return 0 so angular doesn't yell at your for DOM manipulation
]
