//
//  SYResultModel.m
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 27/04/2017.
//  Copyright © 2017 Syan. All rights reserved.
//

#import "SYResultModel.h"
#import "NSCalendar+SY.h"
#import <TFHpple.h>

@interface SYResultModel ()
@property (nonatomic, strong) NSDate *parsedDate;
@end

@implementation SYResultModel

+ (NSArray <SYResultModel *> *)resultsFromWebData:(NSData *)data rootURL:(NSURL *)rootURL
{
    TFHpple *result = [TFHpple hppleWithHTMLData:data];
    
    NSArray <TFHppleElement *> *rows = [result searchWithXPathQuery:@"//table[@id='searchResult']/tr"];
    if (!rows.count)
        rows = [result searchWithXPathQuery:@"//table[@id='searchResult']/tbody/tr"];
    
    NSMutableArray <SYResultModel *> *results = [NSMutableArray array];
    for (TFHppleElement *row in rows)
    {
        TFHppleElement *tdDetails = [row childrenWithTagName:@"td"][1];
        TFHppleElement *tdSE      = [row childrenWithTagName:@"td"][2];
        TFHppleElement *tdLE      = [row childrenWithTagName:@"td"][3];
        
        TFHppleElement *fontChild = [tdDetails firstChildWithTagName:@"font"];
        NSMutableString *dateSizeAndUser = [[fontChild text] mutableCopy];
        if ([fontChild firstChildWithTagName:@"b"])
            [dateSizeAndUser appendString:[[fontChild firstChildWithTagName:@"b"] text]];
        
        if ([fontChild firstChildWithTagName:@"a"])
            [dateSizeAndUser appendString:[[fontChild firstChildWithTagName:@"a"] text]];
        else
            [dateSizeAndUser appendString:[[fontChild firstChildWithTagName:@"i"] text]];
        
        NSArray <NSString *> *components = [dateSizeAndUser componentsSeparatedByString:@", "];
        NSString *date = components[0];
        date = [date stringByReplacingOccurrencesOfString:@"Uploaded " withString:@""];
        
        NSString *size = @"";
        if (components.count >= 2)
            size = [components[1] stringByReplacingOccurrencesOfString:@"Size " withString:@""];
        
        SYResultModel *result = [[SYResultModel alloc] init];
        result.name     = [[[tdDetails firstChildWithTagName:@"div"]
                            firstChildWithTagName:@"a"]
                           text];
        
        if (!result.name.length)
        {
            result.name     = [[[[tdDetails firstChildWithTagName:@"div"]
                                 firstChildWithTagName:@"a"]
                                firstChildWithTagName:@"span"]
                               text];
        }
        
        NSAssert(result.name.length, @"No name for result row");
        
        result.rootURL  = rootURL;
        result.pageURL  = [[[tdDetails firstChildWithTagName:@"div"]
                            firstChildWithTagName:@"a"]
                           objectForKey:@"href"];
        result.seed     = [[tdSE text] integerValue];
        result.leech    = [[tdLE text] integerValue];
        result.verified = [[tdDetails raw] containsString:@"VIP"];
        result.age      = date;
        result.size     = size;
        
        [results addObject:result];
    }
    
    return [results copy];
}

- (void)updateMagnetURLFromWebData:(NSData *)data
{
    TFHpple *webobject = [TFHpple hppleWithHTMLData:data];
    
    NSArray <TFHppleElement *> *links = [webobject searchWithXPathQuery:@"//div[@class='download']/a"];
    
    NSString *magnetURL = nil;
    for (TFHppleElement *link in links)
    {
        NSString *tempURL = [link objectForKey:@"href"];
        if ([tempURL hasPrefix:@"magnet:"])
        {
            magnetURL = tempURL;
            break;
        }
    }
    
    [self setMagnet:magnetURL];
}

- (NSURL *)fullURL
{
    return [NSURL URLWithString:self.pageURL relativeToURL:self.rootURL];
}

- (NSDate *)parsedDate
{
    if (!_parsedDate)
    {
        if ([self.age hasPrefix:@"Today"])
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"'Today 'HH:mm"];
            
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
            _parsedDate = [calendar sy_dateWithDay:[NSDate date]
                                           andTime:[formatter dateFromString:self.age]];
        }
        else if ([self.age hasPrefix:@"Y-day"])
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"'Y-day 'HH:mm"];
            
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
            _parsedDate = [calendar sy_dateWithDay:[NSDate dateWithTimeIntervalSinceNow:-24*3600] // I know, but close enough
                                           andTime:[formatter dateFromString:self.age]];
        }
        else if ([self.age rangeOfString:@":"].location != NSNotFound)
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MM-dd' 'HH:mm"];
            
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
            _parsedDate = [calendar sy_dateWithYear:[NSDate date]
                                         dayAndTime:[formatter dateFromString:self.age]];
        }
        else if (self.age.length)
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MM-dd' 'YYYY"];
            
            _parsedDate = [formatter dateFromString:self.age];
        }
    }
    return _parsedDate;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, %@ (%@, %@), %d/%d, verif: %d>",
            self.class,
            self,
            self.name,
            self.size,
            self.age,
            (int)self.seed,
            (int)self.leech,
            self.verified];
}

@end
