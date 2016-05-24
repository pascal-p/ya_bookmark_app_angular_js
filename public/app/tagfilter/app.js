var app = angular.module("App_tagfilter", ["ngResource", "App_base"]);

//
// Service to build a taglist (label, count) from a bookmark list
//
app.factory("buildTagList", function() {
  return function(bookmarks) {
    var bookmarkCounts = {},
        labels;

    bookmarks.forEach(function(bookmark) {
      var tagList = bookmark.tag_lst;

      tagList.forEach(function(tag) {
        var existing = bookmarkCounts[tag];
        bookmarkCounts[tag] = existing ? existing + 1 : 1;
      });
    });

    labels = Object.keys(bookmarkCounts);
    labels.sort();

    return labels.map(function(label) {
      return { label: label, bookmarkCount: bookmarkCounts[label] };
    });
  };
});

//
// TagListController (to make the taglist available to the view through scope
// notice the watch callback
//

app.controller("TagListController",
  function($scope, state, bookmarks, buildTagList) {
    $scope.bookmarks = bookmarks;

    $scope.$watch("bookmarks", function(updatedBookmarks) {
      console.log( " === watch ===> new value:" + updatedBookmarks + " // length: "  + updatedBookmarks.length);
      $scope.tags = buildTagList(updatedBookmarks);
    }, true); // true compares objects for equality rather than by reference.
  }
);
