//
//  RootViewController.m
//  The Big Picture
//
//  Created by Taylan Pince on 09/06/09.
//  Copyright Taylan Pince 2009. All rights reserved.
//

#import "TheBigPictureAppDelegate.h"
#import "RegexKitLite.h"
#import "RootViewController.h"
#import "ArticleViewController.h"
#import "AboutViewController.h"
#import "ArticleCell.h"
#import "Article.h"


static NSString *const RSS_URL = @"http://www.boston.com/bigpicture/index.xml";
static NSString *const RE_ARTICLE_DESC = @"<div class=\"bpBody\">(.*?)\\(<a href=";
static NSString *const RE_HTML = @"<[a-zA-Z\\/][^>]*>";


@implementation RootViewController

@synthesize articleList, activeContent, dateFormatter, loadingIndicator;


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"The Big Picture";
	
	if ([(TheBigPictureAppDelegate *)[[UIApplication sharedApplication] delegate] isNetworkReachable] == YES) {
		UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshArticles:)];
		
		[refreshButton setEnabled:NO];
		[self.navigationItem setLeftBarButtonItem:refreshButton];
		[refreshButton release];
		
		if (activeContent != nil) [activeContent release];
		if (articleList != nil) [articleList release];
		if (dateFormatter != nil) [dateFormatter release];
		
		activeContent = [[NSMutableString alloc] init];
		articleList = [[NSMutableArray alloc] init];
		dateFormatter = [[NSDateFormatter alloc] init];
		
		[dateFormatter setDateFormat:@"dd MMM yyyy HH:mm:ss ZZZ"];
		
		loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		
		[loadingIndicator setHidesWhenStopped:YES];
		[loadingIndicator startAnimating];
		
		UIBarButtonItem *loadingBarItem = [[UIBarButtonItem alloc] initWithCustomView:loadingIndicator];
		
		[self.navigationItem setRightBarButtonItem:loadingBarItem animated:NO];
		[loadingBarItem release];
		
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		
		[self performSelectorInBackground:@selector(loadArticles) withObject:nil];
	}

	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
	
	[self.navigationItem setBackBarButtonItem:backButton];
	
	[backButton release];
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0.26 green:0.5 blue:0.76 alpha:1.0]];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	
	[self.tableView reloadData];
}


- (void)doneParsing {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[loadingIndicator stopAnimating];
	[self.navigationItem.leftBarButtonItem setEnabled:YES];
	[dateFormatter setDateStyle:NSDateFormatterFullStyle];

	[self.tableView reloadData];
	
	UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	
	[infoButton addTarget:self action:@selector(showInfoView) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *infoBarItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
	
	[self.navigationItem setRightBarButtonItem:infoBarItem animated:YES];
	[infoBarItem release];
	
	NSInteger unreadCount = 0;
	
	for (Article *article in articleList) {
		if (article.unread) unreadCount++;
	}
	
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:unreadCount];
}


- (void)refreshArticles:(id)sender {
	[articleList removeAllObjects];
	[self.tableView reloadData];
	
	[self.navigationItem.leftBarButtonItem setEnabled:NO];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[loadingIndicator startAnimating];
	
	UIBarButtonItem *loadingBarItem = [[UIBarButtonItem alloc] initWithCustomView:loadingIndicator];
	
	[self.navigationItem setRightBarButtonItem:loadingBarItem animated:YES];
	[loadingBarItem release];
	
	[dateFormatter setDateFormat:@"dd MMM yyyy HH:mm:ss ZZZ"];

	[self performSelectorInBackground:@selector(loadArticles) withObject:nil];
}


- (void)showInfoView {
	AboutViewController *controller = [[AboutViewController alloc] initWithNibName:@"AboutView" bundle:nil];
	
	[controller setDelegate:self];
	[controller setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
	
	[self presentModalViewController:controller animated:YES];
	[controller release];
}


- (void)didDismissAboutView {
	[self dismissModalViewControllerAnimated:YES];
}


- (void)loadArticles {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSXMLParser *parser = [[[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:RSS_URL]] autorelease];
	
	[parser setDelegate:self];
	
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	
	[parser parse];
	
	[pool release];
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	[activeContent setString:@""];
	
    if (qName) {
        elementName = qName;
    }
	
	if ([elementName isEqualToString:@"item"]) {
		Article *article = [[Article alloc] init];
		
		[articleList addObject:article];
		[article release];
	}
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {     
    if (qName) {
        elementName = qName;
    }
	
	Article *article = (Article *)[articleList lastObject];
	
    if ([elementName isEqualToString:@"title"]) {
        article.title = activeContent;
    } else if ([elementName isEqualToString:@"description"]) {
		NSArray *descriptionMatch = [activeContent captureComponentsMatchedByRegex:RE_ARTICLE_DESC];
		
		if (descriptionMatch != nil && [descriptionMatch count] > 0) {
			article.description = [[descriptionMatch objectAtIndex:1] stringByReplacingOccurrencesOfRegex:RE_HTML withString:@""];
		}
	} else if ([elementName isEqualToString:@"link"]) {
		article.url = [NSURL URLWithString:activeContent];
	} else if ([elementName isEqualToString:@"guid"]) {
		article.guid = activeContent;
		article.unread = ([[(TheBigPictureAppDelegate *)[[UIApplication sharedApplication] delegate] articleData] objectForKey:article.guid] == nil);
	} else if ([elementName isEqualToString:@"pubDate"]) {
		article.timestamp = [dateFormatter dateFromString:[activeContent substringFromIndex:4]];
	}
	
	[activeContent setString:@""];
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[activeContent appendString:string];
}


- (void)parserDidEndDocument:(NSXMLParser *)parser {
	[self performSelectorOnMainThread:@selector(doneParsing) withObject:nil waitUntilDone:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [articleList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    ArticleCell *cell = (ArticleCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
        cell = [[[ArticleCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
	Article *article = (Article *)[articleList objectAtIndex:indexPath.row];

	cell.mainTitle = article.title;
	cell.unread = article.unread;
	cell.subTitle = [dateFormatter stringFromDate:article.timestamp];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Article *article = (Article *)[articleList objectAtIndex:indexPath.row];
	ArticleViewController *controller = [[ArticleViewController alloc] init];
	
	article.unread = NO;
	controller.article = article;
	
	[self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	Article *article = (Article *)[articleList objectAtIndex:indexPath.row];
	
	CGSize mainSize = [article.title sizeWithFont:[UIFont boldSystemFontOfSize:18.0] constrainedToSize:CGSizeMake(tableView.frame.size.width - 65.0, 600.0f) lineBreakMode:UILineBreakModeWordWrap];

	return mainSize.height + 24.0;
}


- (void)dealloc {
	[activeContent release];
	[articleList release];
	[dateFormatter release];
    [super dealloc];
}


@end
