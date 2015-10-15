import haxe.Timer;
import js.JQuery;
import meteor.Meteor;
import meteor.packages.FlowRouter;
import meteor.Session;
import meteor.Tracker;
import model.Articles;
import model.TagGroups;
import templates.ListArticles;
import templates.ListArticles.ListArticlesOptions;
import templates.NewArticle;
import templates.SideBar;
import templates.ViewArticle;
/**
 * ...
 * @author TiagoLr
 */
class Router {
	
	//-----------------------------------------------
	// Page transitions
	//-----------------------------------------------
	
	// visible pages A and B control which pages are rendered by blaze
	// two pages may be visible at the same time to support fading transitions
	// only visible pages are rendered by the browser
	public var visiblePageA(default, null):String; // TODO
	public var visiblePageB(default, null):String; // TODO
	
	var currentPage(default, null):String;
	function showPage(page:String, ?args:Dynamic) {
		switch (page) {
			case 'listArticles': 
				Client.listArticles.show(args);
			case 'newArticle':
				Client.newArticle.show(args);
			case 'viewArticle':
				Client.viewArticle.show(args);
		}
		
		if (currentPage != page) {
			hidePage(currentPage);
		}
		
		currentPage = page;
	}
	
	function hidePage(page:String) {
		switch(page) {
			case 'listArticles':Client.listArticles.hide();
			case 'newArticle': Client.newArticle.hide();
			case 'viewArticle': Client.viewArticle.hide();
		}
	}
	
	// typed helpers
	function showListArticles(args:ListArticlesOptions) {
		showPage('listArticles', args);
	}
	//-----------------------------------------------
	
	public function new() { }
	
	// Define Routes
	public function init() {
		
		FlowRouter.route('/', {
			action: function() {
				showListArticles({ selector: { }, caption: Configs.client.texts.la_showing_all});   
			}
		});
		
		FlowRouter.route('/articles', {
			action: function() {
				showListArticles({ selector: { }, caption: Configs.client.texts.la_showing_all});   
			}
		});
		
		FlowRouter.route('/articles/tag/:name', {
			action: function () {
				var tag = FlowRouter.getParam('name');
				var selector = { tags: { '$nin':[tag] }}
				
				showListArticles( { selector:selector, caption: Configs.client.texts.la_showing_tag(tag) } );
			} 
		});
		
		FlowRouter.route('/articles/tag/group/:name', {
			action: function () {
				var groupName = FlowRouter.getParam('name');
				var g:TagGroup = TagGroups.collection.findOne( { name:groupName } );
				
				if (g != null) {
					var tags = Shared.utils.resolveTags(g);
					tags.push(g.mainTag);
					
					var selector = { tags: { '$in':tags }};
					showListArticles( { selector: selector, caption: Configs.client.texts.la_showing_group(groupName) } );
				} else if (groupName == 'ungrouped') {
					var tagNames = [];
					var groups = SideBar.tagGroups;
					
					for (g in groups) {
						tagNames.push(g.mainTag);
						for (t in g.resolvedTags) {
							tagNames.push(t.name);
						}
					}
					
					var selector = { tags: { '$nin':tagNames }};
					showListArticles({selector: selector, caption: Configs.client.texts.la_showing_ungrouped}); 
					
				} else {
					FlowRouter.go('/');
				}
			}
		});
		
		FlowRouter.route("/articles/search", {
			action:function () {
				var query = FlowRouter.getQueryParam('q');
				if (query != null && query != "") {
					showListArticles({isSearch:true, selector:null, query:query, caption:Configs.client.texts.la_showing_query(query)});
				} else {
					FlowRouter.go('/');
				}
			}
		});
		
		FlowRouter.route("/articles/new", {
			action:function () {
				showPage('newArticle');
			}
		});
		
		FlowRouter.route("/articles/edit/:_id/:name", {
			action:function () {
				var id = FlowRouter.getParam('_id');
				showPage('newArticle', { articleId:id } );
			}
		});
		
		FlowRouter.route("/articles/view/:_id/:name", {
			action: function () {
				var id = FlowRouter.getParam('_id');
				showPage('viewArticle', { articleId:id } );
			}
		});
		
		FlowRouter.notFound = {
			action: function() {
				Client.utils.notifyInfo('Url not found, redirecting to homepage');
				FlowRouter.go('/');
			}
		};
	}
}