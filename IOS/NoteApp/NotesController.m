//
//  NotesController.m
//  NoteApp
//
//  Created by Todd Vanderlin on 6/4/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import "NotesController.h"
#import "AppDelegate.h"
#import "NoteCreatorController.h"

@interface NotesController ()

@end

@implementation NotesController
@synthesize notes;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[AppDelegate getInstance] makeRequest:@"notes" method:@"GET" params:nil onComplete:^(NSDictionary *data) {

        NSLog(@"%@", [data objectForKey:@"notes"]);
        if([data objectForKey:@"notes"]) {
            notes = [NSMutableArray arrayWithArray:[data objectForKey:@"notes"]];
            
            // now reload the tableview
            [self.tableView reloadData];
        }
        
    }];
    
    
    // Add a new note
    UIBarButtonItem * noteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                 target:self
                                                                                 action:@selector(openNoteCreator:)];
    
    self.navigationItem.rightBarButtonItem = noteButton;
    
}

-(void)openNoteCreator:(id)sender {
    NoteCreatorController * noteVC = [[NoteCreatorController alloc] init];
    noteVC.notesControllerRef = self;
    [self.navigationController presentViewController:noteVC animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addNewNote:(NSDictionary*)note {
    
    // add the new note to the top of our notes array
    [notes insertObject:note atIndex:0];
    
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    
}

-(void)updateNote:(NSDictionary *)note {
    
    NSInteger foundIndex = -1;
    
    // find the note we just updated
    for (NSInteger i=0; i<notes.count; i++) {
        NSDictionary * n = [notes objectAtIndex:i];
        if([[n objectForKey:@"id"] isEqualToString:[note objectForKey:@"id"]]) {
            foundIndex = i;
            break;
        }
    }
    
    // did we find a note - replace with updated note
    if(foundIndex != -1) {
        [notes replaceObjectAtIndex:foundIndex withObject:note];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:foundIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

-(void)removeNote:(NSDictionary *)note {
    
    NSInteger foundIndex = -1;
    
    // find the note we just updated
    for (NSInteger i=0; i<notes.count; i++) {
        NSDictionary * n = [notes objectAtIndex:i];
        if([[n objectForKey:@"id"] isEqualToString:[note objectForKey:@"id"]]) {
            foundIndex = i;
            break;
        }
    }
    
    // did we find a note - remove this note
    if(foundIndex != -1) {
        [notes removeObjectAtIndex:foundIndex];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:foundIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }

}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return notes ? 1 : 0; // safe way to not load rows if notes is nil
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return notes.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    static NSString * cellID = @"NOTES_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    // get the note
    NSDictionary * note = [notes objectAtIndex:indexPath.row];
    
    // create a date formatter so we can display the date
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:-3600]];
    
    [df setDateFormat:@"yyyy-MM-dd H:mm:ss"];
    
    // make a date object from the timestamp
    NSDate * date = [df dateFromString:[note objectForKey:@"created_at"]];


    // change the format weekday/month/day/year hour:min
    [df setDateFormat:@"EE MMM d yyyy h:mm a"];
    NSString * dateStr = [df stringFromDate:date];

    // update the cell
    cell.textLabel.text = [note objectForKey:@"body"];
    cell.detailTextLabel.text = dateStr;
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary * note = [notes objectAtIndex:indexPath.row];
    
    NoteCreatorController * noteVC = [[NoteCreatorController alloc] init];
    noteVC.notesControllerRef = self;
    noteVC.noteRef = note;
    
    [self.navigationController presentViewController:noteVC animated:YES completion:nil];

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
