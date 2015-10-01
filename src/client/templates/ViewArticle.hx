package templates;
import js.JQuery;
import meteor.Meteor;
import meteor.Session;
import meteor.Template;
import model.Articles;
import model.Articles.Article;

/**
 * ...
 * @author TiagoLr
 */
class ViewArticle {

	// Current article to display
	public var currentArticle(default, null):Article;
	
	// Html Page
	public var page(get, null):JQuery;
	function get_page():JQuery {
		return new JQuery('#viewArticlePage');
	}
	
	public function new() {}
	public function init() {
		Template.get('viewArticle').helpers( {
			article : function () {
				return Session.get('currentArticle');
			}
		});
		
	}
	
	public function show(articleId:String) {
		Meteor.subscribe(Articles.NAME, {_id:articleId}); // fetch article with all fields
		Session.set('currentArticle', Articles.collection.findOne( { _id:articleId } ));
		page.show(Router.FADE_DURATION);
	}
	
}