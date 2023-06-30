VideoPlayerController = ($http, $element) ->

  vm = this
  vm.highlight = {}

  vm.init = (video_id) ->
    vm.video_id = video_id
    $http.get("/videos/#{video_id}.json").success (d) ->
      vm.video = d

  vm.createHighlight = ->
    vm.highlight.video_id = vm.video_id
    vm.highlight.offset = (vm.highlight.startMinutes||0)*60 + vm.highlight.startSeconds
    vm.highlight.duration = ((vm.highlight.endMinutes||0)*60 + vm.highlight.endSeconds) - vm.highlight.offset
    $http.post '/highlights.json', highlight: vm.highlight
    .success (highlight) ->
      vm.video.highlights or= []
      vm.video.highlights.unshift highlight
      vm.highlight = {}
      vm.highlightFormVisible = false
    .error (data) ->
      alert "Failure! #{data.join('. ')}"

  vm.jumpToHighlight = (highlight) ->
    iframe = $($element).find('iframe')
    src = iframe.attr 'src'
    without_params = src.replace /\?.*/, ''
    with_new_params = "#{without_params}?start=#{highlight.offset}&end=#{highlight.offset+highlight.duration}&autoplay=1&loop=1"
    iframe.attr 'src', with_new_params
    0 # return 0 so angular doesn't yell at your for DOM manipulation

VideoPlayerController.$inject = ["$http", "$element"]

angular.module('plastic-disco').controller 'VideoPlayerCtrl', VideoPlayerController