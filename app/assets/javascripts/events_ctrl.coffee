EventsController = ($http) ->
  vm = this

  vm.sort = 'desc'

  vm.loadEvents = ->
    vm.loading = true
    params = { query: vm.query, sort: vm.sort }
    if vm.requireVideo
      params.require_video = true
    $http.get '/events/search.json', params: params
    .success (data) ->
      vm.events = data
      vm.loading = false

  vm.loadMore = ->
    params = { query: vm.query, offset: vm.events.length, sort: vm.sort  }
    if vm.requireVideo
      params.require_video = true
    $http.get '/events/search.json', params: params
    .success (data) ->
      vm.events = vm.events.concat data

  vm.typing = _.debounce vm.loadEvents, 200

  vm.seekTo = (event) ->
    loc = event.starts_at_since_epoch - video.starts_at_since_epoch
    window.seek loc

  # This stuff only happens on videos#show

  vm.select = (event) ->
    vm.selectedEvent = event

  vm.clearSelection = ->
    vm.selectedEvent = null

  vm.alignWithoutEvent = ->
    $http.put "/videos/#{vm.video_id}.json", video: { aligned: true }
    .success (data) ->
      alert "Success! Refreshing the page now for review..."
      location.reload()
    .error ->
      alert "Failure!"

  vm.alignWithSelectedEvent = ->
    event.starts_at
    $http.post "/videos/#{vm.video_id}/align_to_event.json", { event_id: vm.selectedEvent.id, seconds_into_clip: vm.secondsIntoClip, minutes_into_clip: vm.minutesIntoClip }
    .success (data) ->
      alert "Success! Refreshing the page now for review..."
      location.reload()
    .error (data) ->
      alert "Failure! Did you input seconds and minutes?"

  vm.saveOffset = ->
    debugger
    $http.post "/videos/#{vm.video_id}/offset.json", offset: vm.offset
    .success (data) ->
      alert "Success! Refreshing the page now for review..."
      location.reload()
    .error ->
      alert "Failure!"

  vm.init = (video_id, options = {}) ->
    # only videos#show uses the init function
    vm.video_id = video_id
    $http.get("/videos/#{video_id}.json").success (d) -> vm.video = d
    vm.sort = options.sort if options.sort?
    vm.loadEvents()

  vm.loadEvents()

EventsController.$inject = ['$http']

angular.module('plastic-disco').controller 'EventsCtrl', EventsController