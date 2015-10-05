//
//  SYComputerFormCell.m
//  TorrentAdder
//
//  Created by Stan Chevallier on 05/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYComputerFormCell.h"
#import "SYComputerModel.h"
#import "UIImage+SY.h"
#import "UIColor+SY.h"

@interface SYComputerFormCell () <UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UIImageView *iconView;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, assign) SYComputerModelField  field;
@property (nonatomic, strong) SYComputerModel       *computer;
@end

@implementation SYComputerFormCell

- (void)setComputer:(SYComputerModel *)computer andField:(SYComputerModelField)field
{
    [self setComputer:computer];
    [self setField:field];
    
    [self.iconView setImage:[[computer imageForField:field] imageMaskedWithColor:[UIColor lightBlueColor]]];
    [self.textField setKeyboardType:[computer keyboardTypeForField:field]];
    
    NSArray *options = [computer optionsForEnumField:field];
    if (options)
    {
        [self.segmentedControl setHidden:NO];
        [self.segmentedControl removeAllSegments];
        for (NSUInteger i = 0; i < [options count]; ++i)
            [self.segmentedControl insertSegmentWithTitle:options[i] atIndex:i animated:NO];
        [self.segmentedControl setSelectedSegmentIndex:[[computer valueForField:field] intValue]];
        [self.textField setHidden:YES];
    }
    else
    {
        [self.segmentedControl setHidden:YES];
        [self.textField setHidden:NO];
        [self.textField setPlaceholder:[computer nameForField:field]];
        [self.textField setText:[computer valueForField:field]];
        [self.textField setTextAlignment:NSTextAlignmentRight];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.computer setValue:textField.text forField:self.field];
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)textFieldTextUpdated:(UITextField *)textField
{
    [self.computer setValue:textField.text forField:self.field];
}

- (IBAction)segmentedControlUpdated:(UISegmentedControl *)control
{
    [self.computer setValue:@(control.selectedSegmentIndex) forField:self.field];
}

@end
