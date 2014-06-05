//
//  NoteCreatorController.m
//  NoteApp
//
//  Created by Todd Vanderlin on 6/4/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import "NoteCreatorController.h"
#import "AppDelegate.h"
#import "NotesController.h"

@interface NoteCreatorController ()

@end

@implementation NoteCreatorController

@synthesize noteTextView, notesControllerRef, noteRef;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIToolbar * toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    
    
    // close button
    UIBarButtonItem * closeBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close)];

    // spacer
    UIBarButtonItem * spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    // save button
    UIBarButtonItem * saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    
    // delete button
    UIBarButtonItem * deleteBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteNote)];
    
    // set the items for toolbar
    toolbar.items = @[closeBtn, spacer, saveBtn, deleteBtn];
    
    [self.view addSubview:toolbar];
    
    noteTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 70, self.view.frame.size.width-40, 170)];
    noteTextView.backgroundColor = [UIColor lightGrayColor];
    noteTextView.delegate = self;
    [self.view addSubview:noteTextView];
    
    // auto launch the keyboard
    if(noteRef == nil) {
        [noteTextView becomeFirstResponder];
    }
    else {
        noteTextView.text = [noteRef objectForKey:@"body"];
    }
}

-(void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)save {
    
    // if the keyboard is up dismiss it
    if([noteTextView isFirstResponder]) {
        [noteTextView resignFirstResponder];
    }
    
    NSString * body = noteTextView.text;
    
    // if we have a note ref then update else save the note
    
    if(noteRef) {
        
        // We first create the path notes/{note id}
        // The verbs PUT/UPDATE/DELETE are not supported
        // with most browsers/clients so we need to pass
        // a _method. Laravel knows how to interespt this
        // into the correct method.
        
        NSString * noteURL = [NSString stringWithFormat:@"notes/%@", [noteRef objectForKey:@"id"]];
        [[AppDelegate getInstance] makeRequest:noteURL
                                        method:@"POST"
                                        params:@{@"body": body, @"_method": @"PUT"}
                                    onComplete:^(NSDictionary *data) {
                                        
                                        // we need to dismiss the view controller
                                        // and update the tableview in NotesController
                                        [self dismissViewControllerAnimated:YES completion:^{
                                            [notesControllerRef updateNote:[data objectForKey:@"note"]];
                                        }];
                                        
                                    }];
        
    }
    else {
        [[AppDelegate getInstance] makeRequest:@"notes"
                                        method:@"POST"
                                        params:@{@"body": body}
                                    onComplete:^(NSDictionary *data) {
                                        
                                        // we need to dismiss the view controller
                                        // and update the tableview in NotesController
                                        [self dismissViewControllerAnimated:YES completion:^{
                                            [notesControllerRef addNewNote:[data objectForKey:@"note"]];
                                        }];
                                        
                                    }];
    }
    
}

-(void)deleteNote {
    NSString * noteURL = [NSString stringWithFormat:@"notes/%@", [noteRef objectForKey:@"id"]];
    [[AppDelegate getInstance] makeRequest:noteURL
                                    method:@"POST"
                                    params:@{@"_method": @"DELETE"}
                                onComplete:^(NSDictionary *data) {
                                    
                                    // we need to dismiss the view controller
                                    // and update the tableview in NotesController
                                    [self dismissViewControllerAnimated:YES completion:^{
                                        [notesControllerRef removeNote:[data objectForKey:@"note"]];
                                    }];
                                    
                                }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
