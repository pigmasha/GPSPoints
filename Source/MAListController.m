//
//  MAListController.m
//  GPSPoints
//
//  Created by M on 26.03.15.
//
//

#import "MAListController.h"
#import "MAController.h"

@interface MAListController ()<UIPopoverControllerDelegate>
{
    NSString* _str;
    UIPopoverController* _popover;
}
@end

//=================================================================================

@implementation MAListController

//---------------------------------------------------------------------------------
- (void)dealloc
{
    [_str release];
    [_popover release];
    [super dealloc];
}

//---------------------------------------------------------------------------------
- (void)loadView
{
    [super loadView];
    self.title = LSTR(@"L_Title");
    
    _str = [[NSMutableString alloc] init];
    [MA_CONTROLLER pointsToStr: (NSMutableString*)_str];
    
    UITextView* t = [[UITextView alloc] initWithFrame: self.view.bounds];
    t.autoresizingMask = SZ(Width) | SZ(Height);
    t.text = _str;
    t.editable = NO;
    t.font = [UIFont systemFontOfSize: 15];
    [self.view addSubview: t];
    [t release];
}

//---------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([UIActivityViewController class])
    {
        UIBarButtonItem* bt = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAction target: self action: @selector(onAct)];
        self.navigationItem.rightBarButtonItem = bt;
        [bt release];
    }
}

//---------------------------------------------------------------------------------
- (void)onAct
{
    NSArray* dataToShare = [[NSArray alloc] initWithObjects: _str, nil];
    
    UIActivityViewController* vc = [[UIActivityViewController alloc] initWithActivityItems: dataToShare applicationActivities:nil];
    [dataToShare release];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        if (!_popover)
        {
            _popover = [[UIPopoverController alloc] initWithContentViewController: vc];
            _popover.delegate = self;
        }
        if (![_popover isPopoverVisible])
        {
            [_popover presentPopoverFromBarButtonItem: self.navigationItem.rightBarButtonItem permittedArrowDirections: UIPopoverArrowDirectionAny animated: YES];
        } else {
            [_popover dismissPopoverAnimated:YES];
            [_popover release];
            _popover = nil;
        }
    } else {
        [self presentViewController: vc animated: YES completion: nil];
    }
    
    [vc release];
}

//---------------------------------------------------------------------------------
// <UIPopoverControllerDelegate>
//---------------------------------------------------------------------------------
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [_popover release];
    _popover = nil;
}

@end
