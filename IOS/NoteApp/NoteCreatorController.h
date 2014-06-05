//
//  NoteCreatorController.h
//  NoteApp
//
//  Created by Todd Vanderlin on 6/4/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotesController.h"

@interface NoteCreatorController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) UITextView * noteTextView;
@property (weak, nonatomic) NotesController * notesControllerRef;
@property (weak, nonatomic) NSDictionary * noteRef;
@end
