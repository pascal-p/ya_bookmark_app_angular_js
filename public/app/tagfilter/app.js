var app = angular.module("App_tagfilter", ["ngResource", "App_base"]);

//
// A service to define a common state (updated from App_base)
//
app.service("state", function(Bookmark) {
  this.formBookmark = {bookmark:new Bookmark()};
  this.clearForm = function() {
    this.formBookmark.bookmark = new Bookmark();
  };

  this.bookmarkFilter = {filterTag:""};
});

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
// Filter for tags
//
app.filter("filterByTag", function() { // no dependencies

  var byTag = function(filterTag) {
    return function(bookmark) {
      var tagList  = bookmark.tag_lst,
          noFilter = (!filterTag) || (filterTag.length == 0),
          tagListContainsFilterTag = tagList && tagList.indexOf(filterTag) > -1;

      return noFilter || tagListContainsFilterTag;
    };
  };

  return function(bookmarks, filterTag) {
    return bookmarks.filter(byTag(filterTag));
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
      $scope.tags = buildTagList(updatedBookmarks);
    }, true); // true compares objects for equality rather than by reference.

    $scope.filterBy = function(tag) {
      state.bookmarkFilter.filterTag = tag.label;
    };
  }
);

app.controller("BookmarkListController",
  function($scope, state, bookmarks, editBookmark, deleteBookmark) {
    $scope.bookmarks      = bookmarks;
    $scope.bookmarkFilter = state.bookmarkFilter;
    //
    $scope.filterBy = function(tag) {
      state.bookmarkFilter.filterTag = tag;
    };
    $scope.deleteBookmark = deleteBookmark;
    $scope.editBookmark = editBookmark;
  }
);

app.controller("TagFilterController", function($scope, state) {
  $scope.bookmarkFilter = state.bookmarkFilter;
  $scope.clearFilter = function() {
    state.bookmarkFilter.filterTag = "";
  };
});
