//
//  MAPointsController.m
//  GPSPoints
//
//  Created by M on 24.03.15.
//
//

#import "MAPointsController.h"
#import "MAController.h"
#import "MAFmtController.h"
#import "MANewController.h"
#import "MAListController.h"
#import "MAPointCell.h"
#import "MATableXView.h"
#import "MASegmCell.h"

@interface MAPointsController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSString* _date;
    MATableXView* _table;
    MASegmCell* _segm;
    UISwitch* _rot;
}
@end

//=================================================================================

@implementation MAPointsController

static MAPointsController* _s_inst = nil;

+ (instancetype)sharedInstance
{
    return _s_inst;
}

//---------------------------------------------------------------------------------
- (void)loadView
{
    _s_inst = self;
    [super loadView];
    self.title = LSTR(@"P_Title");
    
    NSString* path = [[NSBundle mainBundle] executablePath];
    NSDate* d = [[[NSFileManager defaultManager] attributesOfItemAtPath: path error: nil] fileModificationDate];
    _date = [[NSDateFormatter localizedStringFromDate: d dateStyle: NSDateFormatterMediumStyle timeStyle: NSDateFormatterNoStyle] retain];
    
    _segm = [[MASegmCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: nil];
    
    _rot = [[UISwitch alloc] init];
    _rot.on = SETT_BOOL_VAL(SETT_ROT);
    [_rot addTarget: self action: @selector(onRot) forControlEvents: UIControlEventValueChanged];
    
    _table = [[MATableXView alloc] initWithFrame: self.view.bounds style: UITableViewStyleGrouped];
    _table.autoresizingMask = SZ(Width) | SZ(Height);
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview: _table];
    [_table release];
    [_table reloadData];
}

//---------------------------------------------------------------------------------
- (void)dealloc
{
    if (_s_inst == self) _s_inst = nil;
    [_date release];
    [_segm release];
    [_rot release];
    [super dealloc];
}

//---------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem* b = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"icon_navbar_cancel"] style: UIBarButtonItemStylePlain target: self action: @selector(onCancel)];
    self.navigationItem.leftBarButtonItem = b;
    [b release];
}

//---------------------------------------------------------------------------------
- (void)onCancel
{
    [self.presentingViewController dismissViewControllerAnimated: YES completion: NULL];
}

//---------------------------------------------------------------------------------
- (void)reloadData
{
    [_table reloadData];
}

//---------------------------------------------------------------------------------
- (void)onRot
{
    SETT_SET_BOOL_VAL(SETT_ROT, _rot.on);
    [MA_CONTROLLER settRotChanged];
}

//---------------------------------------------------------------------------------
// <UITableViewDataSource>
//---------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

//---------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 3) return 3;
    if (section == 2) return 4;
    return (section == 0 && [[MA_CONTROLLER points] count]) ? [[MA_CONTROLLER points] count] : 1;
}

//---------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? LSTR(@"P_My") : ((section == 3) ? LSTR(@"P_About") : nil);
}

#define MA_PT_CELL_ID @"P2"

//---------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        MAPointCell* cell = [tableView dequeueReusableCellWithIdentifier: [MAPointCell identifier]];
        if (!cell) cell = [[[MAPointCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: [MAPointCell identifier]] autorelease];
        if ([[MA_CONTROLLER points] count])
        {
            [cell setName: [[[MA_CONTROLLER points] objectAtIndex: indexPath.row] firstObject]
                 andCoord: [[MA_CONTROLLER ptStrs] objectAtIndex: indexPath.row]];
        } else {
            [cell setName: LSTR(@"P_No") andCoord: @""];
        }
        return cell;
    }
    
    if (indexPath.section == 2 && indexPath.row == 0) return _segm;
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: MA_PT_CELL_ID];
    if (!cell) cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: MA_PT_CELL_ID] autorelease];
    
    BOOL isRot = (indexPath.section == 2 && indexPath.row == 1);
    cell.accessoryType = ((indexPath.section == 1 || indexPath.section == 2) && !isRot) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    cell.accessoryView = (isRot) ? _rot : nil;
    
    switch (indexPath.section)
    {
        case 1:
            cell.selectionStyle = CELL_SEL_DEF;
            cell.textLabel.text = LSTR(@"P_New");
            cell.detailTextLabel.text = @"";
            break;
        case 2:
        {
            cell.selectionStyle = (isRot) ? UITableViewCellSelectionStyleNone : CELL_SEL_DEF;
            if (isRot)
            {
                cell.textLabel.text = LSTR(@"P_Rotate");
                cell.detailTextLabel.text = @"";
            } else {
                cell.textLabel.text = (indexPath.row == 2) ? LSTR(@"P_Fmt") : LSTR(@"P_List");
                if (indexPath.row == 2)
                {
                    int f = [MA_CONTROLLER fmt];
                    cell.detailTextLabel.text = (f == MACoorDegMin) ? LSTR(@"F_2") : ((f == MACoorDegMinSec) ? LSTR(@"F_3") : LSTR(@"F_1"));
                } else {
                    cell.detailTextLabel.text = @"";
                }
            }
            break;
        }
        case 3:
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            switch (indexPath.row)
            {
                case 1:
                    cell.textLabel.text = LSTR(@"P_Ver");
                    cell.detailTextLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleShortVersionString"];
                    break;
                case 2:
                    cell.textLabel.text = LSTR(@"P_Date");
                    cell.detailTextLabel.text = _date;
                    break;
                default:
                    cell.textLabel.text = LSTR(@"P_Name");
                    cell.detailTextLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleDisplayName"];
                    break;
            }
        }
        default: break;
    }
    
    return cell;
}

//---------------------------------------------------------------------------------
// <UITableViewDelegate>
//---------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
            if ([[MA_CONTROLLER points] count])
            {
                [MA_CONTROLLER setPoint: [[MA_CONTROLLER points] objectAtIndex: indexPath.row] isShow: ([_table lastX] < self.view.bounds.size.width - 50)];
                [self onCancel];
            }
            break;
        case 1:
        {
            UIViewController* vc = [[MANewController alloc] initWithPt: nil isNew: YES];
            [self.navigationController pushViewController: vc animated: YES];
            [vc release];
            break;
        }
        case 2:
        {
            if (indexPath.row < 2) return;
            UIViewController* vc = (indexPath.row == 2) ? [[MAFmtController alloc] initWithStyle: UITableViewStyleGrouped] : [[MAListController alloc] initWithNibName: nil bundle: nil];
            [self.navigationController pushViewController: vc animated: YES];
            [vc release];
            break;
        }
    }
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
}

//---------------------------------------------------------------------------------
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 0 && [[MA_CONTROLLER points] count]) ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

//---------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && indexPath.row == 0) return SEGM_ROW_H;
    return (indexPath.section == 0) ? POINT_ROW_H : tableView.rowHeight;
}

//---------------------------------------------------------------------------------
- (NSArray *)tableView: (UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && [[MA_CONTROLLER points] count])
    {
        int r = (int)indexPath.row;
        UITableViewRowAction* act1 = [UITableViewRowAction rowActionWithStyle: UITableViewRowActionStyleNormal title: LSTR(@"N_Edit") handler: ^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            UIViewController* vc = [[MANewController alloc] initWithPt: [[MA_CONTROLLER points] objectAtIndex: r] isNew: YES];
            [self.navigationController pushViewController: vc animated: YES];
            [vc release];
        }];
        UITableViewRowAction* act2 = [UITableViewRowAction rowActionWithStyle: UITableViewRowActionStyleDestructive title: LSTR(@"N_Del")
                                                                      handler: ^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            [MA_CONTROLLER deletePoint: r];
            [_table reloadData];
        }];
        return [NSArray arrayWithObjects: act2, act1, nil];
    }
    return nil;
}

//---------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete && indexPath.section == 0)
    {
        [MA_CONTROLLER deletePoint: (int)indexPath.row];
        [_table reloadData];
    }
}

@end
