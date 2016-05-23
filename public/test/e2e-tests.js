
describe("Bookmark list", function() {

  beforeEach(function() {
    browser().navigateTo("/");
  });

  
  it("should display a bookmark list", function() {
    expect(repeater("li.bookmark").count()).toBeGreaterThan(0);
  });

  it("should add a new bookmark", function() {
    var bookmarkCount = repeater("li.bookmark").count();
    
    bookmarkCount.execute(function() {});
    var previousCount = bookmarkCount.value;
    input("formBookmark.bookmark.url").
      enter("http://docs.angularjs.org/guide/dev_guide.e2e-testing");
    input("formBookmark.bookmark.title").
      enter("AngularJS end-to-end testing guide");
    element("input:submit").click();
    expect(repeater("li.bookmark").count()).toBe(previousCount + 1);
  });
  
});
