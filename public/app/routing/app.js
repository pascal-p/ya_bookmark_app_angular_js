var app = angular.module(
  "App_routing",
  [
    "ngResource",
    "ngMessages",
    "ngRoute",
    "App_base",
    "App_pre_tag_validation",
    "App_tagfilter",
    "App_validation"
  ],                         
  function($routeProvider) {
    var params = {
      controller: "BookmarkListController",
      templateUrl:"/app/routing/bookmark_list.html"
    };
    
    $routeProvider.when("/", params).
      when("/filter/:tag", params);
  }
);

app.controller("BookmarkListController",
  function($scope, $routeParams, state, bookmarks, editBookmark, deleteBookmark) {
    $scope.bookmarks = bookmarks;
    $scope.bookmarkFilter = state.bookmarkFilter;
    state.bookmarkFilter.filterTag = $routeParams.tag;
    $scope.editBookmark = editBookmark;
    $scope.deleteBookmark = deleteBookmark;
  }
);

app.controller("TagListController",
  function($scope, $routeParams, state, bookmarks, buildTagList) {
    $scope.bookmarks = bookmarks;
    state.bookmarkFilter.filterTag = $routeParams.tag;
    $scope.$watch("bookmarks", function(updatedBookmarks) {
      $scope.tags = buildTagList(updatedBookmarks);
    }, true);
  }
);

app.controller("TagFilterController",
  function($scope, $routeParams, state) {
    $scope.bookmarkFilter = state.bookmarkFilter;
    state.bookmarkFilter.filterTag = $routeParams.tag;
  }
);

