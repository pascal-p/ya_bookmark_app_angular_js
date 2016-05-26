var app = angular.module("App_pre_tag_validation",
                         [
                           "ngResource",
                           "ngMessages",
                           "App_base"
                         ]);

//
// Controller for the bookmark form
//
app.controller("BookmarkFormController",
  function($scope, state, bookmarks, saveBookmark) {
    $scope.formBookmark = state.formBookmark;
    $scope.urlRegExp = /^http(s)?:\/\/(\w+:{0,1}\w*@)?(\S+)(:\d+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?$/;
    $scope.saveBookmark = saveBookmark;
    $scope.clearForm = state.clearForm;
  }
);
