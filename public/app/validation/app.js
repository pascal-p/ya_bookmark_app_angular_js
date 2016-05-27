var app = angular.module("App_validation",
                         [
                           "ngResource",
                           "ngMessages",
                           "App_base",
                           "App_pre_tag_validation",
                           "App_tagfilter"
                         ]);

app.factory("tagsRegExp", function() {
  return /^\w+\s*$|^\w+\s*,[\s*\w+,]+$/;
});

//
// service to save (to the backend) and update the bookmark list
//
app.factory("saveBookmark", function(bookmarks, state) {
  return function(bookmark, form) {
    var ix = -1;
    if (!bookmark.id) {
      bookmarks.push(bookmark);
      ix = bookmarks.indexOf(bookmark);
      console.log(bookmarks);
    }
    if (form.$valid) {
      bookmark.$save(
        function success(resp) {
          console.log("Success:" + JSON.stringify(resp));
          state.clearForm();
          form.$setPristine();
          form.$setUntouched();
        },
        function error(errorResp) {
          console.log("Error:" + JSON.stringify(errorResp));
          bookmarks.splice(ix, 1);
        }
      );
    }
  };
});

//
// Controller for the bookmark form
//
app.controller("BookmarkFormController",
  function($scope, state, tagsRegExp, bookmarks, saveBookmark) {
    $scope.formBookmark = state.formBookmark;
    $scope.tagsRegExp   = tagsRegExp;
    $scope.saveBookmark = saveBookmark;
    $scope.clearForm    = state.clearForm;
  }
);

//
