// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require_self
//= require_tree .

angular.module('plastic-disco', []);

// some simple code I got off the interwebs to retain form
// values when the back button is used, if you add 
// < app-init-from-view > to the tag.
// http://jsfiddle.net/tchatel/a8674/
angular.module('plastic-disco').directive('initValueFromView', ['$parse', function($parse) {
  return {
    restrict: 'A',
    link: function(scope, element, attrs) {
      var modelVar = attrs.ngModel;
      var scopeGet = $parse(modelVar);
      var scopeSet = scopeGet.assign;
      scopeSet(scope, element.val());        
    }
  };
}]);
