var app = angular.module("App_base", ["ngResource"]);

//
// service named Bookmark that CRUD bookmarks between the client and the server
//
app.factory("Bookmark", function($resource) {
  return $resource("/bookmarks/:id", {id:"@id"});
});

//
// defined the bookmarks service to provide the bookmark list
//
app.factory("bookmarks", function(Bookmark) {
  return Bookmark.query();
});

//
// A service to be used by other services
//
app.service("state", function(Bookmark) {
  this.formBookmark = {bookmark:new Bookmark()};
  this.clearForm = function() {
    this.formBookmark.bookmark = new Bookmark();
  };
});

//
// service to save (to the backend) and update the bookmark list
//
app.factory("saveBookmark", function(bookmarks, state) {
  return function(bookmark) {
    if (!bookmark.id) {
      bookmarks.push(bookmark);
    }
    bookmark.$save();
    state.clearForm();
  };
});

//
// service to delete a bookmark entries (on the backend) and update
// the (local) bookmark list
//
app.factory("deleteBookmark", function(bookmarks) {
  return function(bookmark) {
    var ix = bookmarks.indexOf(bookmark);
    bookmark.$delete();
    bookmarks.splice(ix, 1);
  };
});

//
// A service to edit a bookmark using the state service defined above
//
app.factory("editBookmark", function(state) {
  return function(bookmark) {
    state.formBookmark.bookmark = bookmark;
  };
});

//
// Controller for the bookmark list
//
app.controller("BookmarkListController",
  function($scope, bookmarks, deleteBookmark, editBookmark) {
    $scope.bookmarks = bookmarks;
    $scope.deleteBookmark = deleteBookmark;
    $scope.editBookmark = editBookmark;
  }
);

//
// Controller for the bookmark form
//
app.controller("BookmarkFormController",
  function($scope, state, bookmarks, saveBookmark) {
    $scope.formBookmark = state.formBookmark;
    $scope.saveBookmark = saveBookmark;
    $scope.clearForm = state.clearForm;
  }
);

//