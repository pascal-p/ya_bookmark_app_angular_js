var app = angular.module("App_pre_tag_validation",
                         [
                           "ngResource",
                           "ngMessages",
                           "App_base"
                         ]);


app.factory("urlRegExp", function() {
  return /^http(s)?:\/\/(\w+:{0,1}\w*@)?(\S+)(:\d+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?$/;
});


//
// Controller for the bookmark form
//
app.controller("BookmarkFormController",
  function($scope, state, urlRegExp, bookmarks, saveBookmark) {
    $scope.formBookmark = state.formBookmark;
    $scope.urlRegExp    = urlRegExp;
    $scope.saveBookmark = saveBookmark;
    $scope.clearForm = state.clearForm;
  }
);
