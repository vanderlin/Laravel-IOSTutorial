//
//  NotesController.h
//  NoteApp
//
//  Created by Todd Vanderlin on 6/4/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotesController : UITableViewController
@property (strong, nonatomic) NSMutableArray * notes;

-(void)addNewNote:(NSDictionary*)note;
-(void)updateNote:(NSDictionary*)note;
-(void)removeNote:(NSDictionary*)note;
@end
