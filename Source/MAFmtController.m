//
//  MAFmtController.m
//  GPSPoints
//
//  Created by M on 24.03.15.
//
//

#import "MAFmtController.h"
#import "MAController.h"

@implementation MAFmtController

- (void)loadView
{
    [super loadView];
    self.title = LSTR(@"F_Title");
}

//---------------------------------------------------------------------------------
// <UITableViewDataSource>
//---------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return MACoorLast - 1;
}

#define MA_FMT_CELL_ID @"F1"

//---------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: MA_FMT_CELL_ID];
    if (!cell) cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: MA_FMT_CELL_ID] autorelease];
    
    cell.accessoryType = (indexPath.row + 1 == [MA_CONTROLLER fmt]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    switch (indexPath.row)
    {
        case MACoorDegMin - 1:
            cell.textLabel.text = LSTR(@"F_2");
            break;
        case MACoorDegMinSec - 1:
            cell.textLabel.text = LSTR(@"F_3");
            break;
        default:
            cell.textLabel.text = LSTR(@"F_1");
            break;
    }
    
    return cell;
}

//---------------------------------------------------------------------------------
// <UITableViewDelegate>
//---------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MA_CONTROLLER setFmt: (int)indexPath.row + 1];
    [self.tableView reloadData];
}


@end
