//
//  RootViewController.m
//  The Big Picture
//
//  Created by Taylan Pince on 09/06/09.
//  Copyright Taylan Pince 2009. All rights reserved.
//

#import "RootViewController.h"
#import "ArticleViewController.h"
#import "Article.h"


static NSString *rssURL = @"http://www.boston.com/bigpicture/index.xml";


@implementation RootViewController

@synthesize articleList, activeContent, dateFormatter;


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"The Big Picture";
	
	UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshArticles:)];
	
	[self.navigationItem setLeftBarButtonItem:refreshButton];
	[refreshButton release];
	
	activeContent = [[NSMutableString alloc] init];
	articleList = [[NSMutableArray alloc] init];
	dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"dd MMM yyyy HH:mm:ss ZZZ"];
	
	[self performSelectorInBackground:@selector(loadArticles) withObject:nil];
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
}


- (void)doneParsing {
	[self.tableView reloadData];
}


- (void)refreshArticles:(id)sender {
	[articleList removeAllObjects];
	[self.tableView reloadData];
	
	[self performSelectorInBackground:@selector(loadArticles) withObject:nil];
}


- (void)loadArticles {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[[NSURLCache sharedURLCache] setMemoryCapacity:0];
	[[NSURLCache sharedURLCache] setDiskCapacity:0];
	
	NSXMLParser *parser = [[[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:rssURL]] autorelease];
	
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
		[articleList addObject:[[Article alloc] init]];
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
		article.description = activeContent;
	} else if ([elementName isEqualToString:@"link"]) {
		article.url = [NSURL URLWithString:activeContent];
	} else if ([elementName isEqualToString:@"guid"]) {
		article.guid = activeContent;
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
	[activeContent release];
	[articleList release];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [articleList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
	Article *article = (Article *)[articleList objectAtIndex:indexPath.row];
    
	cell.textLabel.text = article.title;
	cell.detailTextLabel.text = [article.timestamp description];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ArticleViewController *controller = [[ArticleViewController alloc] init];
	
	controller.article = [articleList objectAtIndex:indexPath.row];
	
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}


- (void)dealloc {
	[activeContent release];
	[articleList release];
	[dateFormatter release];
    [super dealloc];
}


@end
