//
//  SYAlertManager.m
//  TorrentAdder
//
//  Created by Stan Chevallier on 30/09/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYAlertManager.h"
#import "SYAppDelegate.h"
#import "SYComputerModel.h"
#import "BlocksKit+UIKit.h"

@implementation SYAlertManager

+ (void)showHelpMagnetAlertForComputer:(SYComputerModel *)computer
{
    NSString *message = [NSString stringWithFormat:@"To add a torrent to %@ you need to open this app with a magnet. Go to Safari, open a page with a magnet link in it, click the magnet to open this app, and then select %@ to start downloading the torrent.",
                         computer.name,
                         computer.name];
    
    [[[UIAlertView alloc] initWithTitle:@"No torrent provided"
                                message:message
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"Close", nil] show];
}

+ (void)showMagnetAddedToComputer:(SYComputerModel *)computer
                      withMessage:(NSString *)computerMessage
                            error:(NSError *)error
                        backToApp:(BOOL)backToApp
                            block:(void (^)(BOOL))block
{
    if (error)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error while adding torrent"
                                    message:error.localizedDescription
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Close", nil] show];
        return;
    }
    
    NSString *message = @"";
    
    if (computerMessage.length)
        message = [NSString stringWithFormat:@"Message from %@: %@", computer.name, computerMessage];
    
    if (!backToApp)
    {
        
        [[[UIAlertView alloc] initWithTitle:@"Torrent added successfully"
                                    message:(message.length ? message : nil)
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Close", nil] show];
        return;
    }
    
    message = [message stringByAppendingFormat:@"%@Do you want to open the app you came from?",
               (message.length ? @"\n\n" : @"")];
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Torrent added successfully"
                                                 message:(message.length ? message : nil)
                                                delegate:self
                                       cancelButtonTitle:nil
                                       otherButtonTitles:nil];
    [av bk_addButtonWithTitle:@"Yes" handler:^{
        if (block) block(YES);
    }];
    [av bk_setCancelButtonWithTitle:@"No" handler:^{
        if (block) block(NO);
    }];
    [av show];
}

@end
