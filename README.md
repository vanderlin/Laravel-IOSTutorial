# Laravel & IOS
We are going to build an app that will read and write to a Laravel API. 

# Create App

Create a new Laravel app called noteApp.
`composer create-project laravel/laravel noteApp --prefer-dist`

Add the [Way Generators](https://github.com/vanderlin/LaravelTutorial/blob/master/readme.md#add-ways-generators) 

Update composer.
`composer update`

Turn on MAMP and test the site. 

# Setup Database
open `/app/config/database.php` and set you mysql credentials. We are using MAMP so just use the defaults. [Create](https://github.com/vanderlin/LaravelTutorial/blob/master/readme.md#mamp-database) or use an existing database locally. 
> Note: If you are using a existing database its good practice to set a prefix in the `database.php`.  

You should have something like this.
```
'mysql' => array(
			'driver'    => 'mysql',
			'host'      => 'localhost',
			'database'  => 'app',
			'username'  => 'root',
			'password'  => 'root',
			'charset'   => 'utf8',
			'collation' => 'utf8_unicode_ci',
			'prefix'    => 'notes_',
		),
```

# Build a Resource
We are going to create an app that creates notes, so we want to create a new resource call `note`.

Run.
`php artisan generate:resource note --fields="body:text"`

Open `app/routes.php` and a the new resource. 
`Route::Resource('notes', 'NotesController');`

Test your new routes. In terminal type
`php artisan routes`	
Your should see all the new verbs for creating/updating/deleting `notes`.

Open `app/controllers/notesController.php` and the the functionality for creating updating and deleting notes.

Your file should look like this.
```
<?php

class NotesController extends \BaseController {

	// GET
	public function index() {
		return Note::all();
	}

	// POST
	public function store() {
		$note = new Note();
		$note->body = Input::get('body', 'empty note');
		$note->save();

		return Response::json($note);
	}

	// GET
	public function show($id) {
		$note = Note::find($id);
		return $note;
	}

	// PUT
	public function update($id) {
		$note = Note::find($id);
		$note->body = Input::get('body', 'empty note');
		$note->save();
		
		return Response::json($note);
	}

	// DELETE 
	public function destroy($id) {
		$note = Note::find($id);
		$note->delete();
		return Response::json($note);
	}

}
```

# Test the API.
- In [Chrome](https://www.google.com/intl/en-US/chrome/browser/) get the app called [PostMan](https://chrome.google.com/webstore/detail/postman-rest-client/fdmmgilgnpjigdojojpjoooidkmcomcm?hl=en) this is a nice little REST app for Chrome that allows you to test all the verbs for you API.

Looking at your routes `php artisan routes` you can see how to all the URIs.

**POST** a new `Note`. Add the key `body` and value `my new note`.
http://laraveldemo:8888/notes

**GET** all the `Notes`. 
http://localhost:8888/notes

**DELETE** a `Note`.
http://localhost:8888/notes/1

# IOS
Open XCode and create a new IOS project and select *Single View Application*. Name is NoteApp, select iPhone and save.

### Setup the Main.storyboard
Delete everything in the `Main.storyboard`. Select the file and hit *(⌘+a) then (delete)*		
Delete the `ViewController.h` and `ViewController.m` files.

### Create NotesController
File new. *(⌘+n)*
Cocoa Touch -> Objective-C class
Click Next		
Class: NotesController
Subclass of: UITableViewController		
Click Next	
Create

Click on the `Main.storyboard` and drag a new `Table View Controller` to the stage. With the Controller selected third button at the top of the inspector. Set the `Custom Class` to `NotesController`. Now in the top menu click *Editor -> Embed In -> Navigation Controller*

Hit  *(⌘+r)* and test the app. Everything should be connected and you should see a TableViewController in the simulator. 

### Load the data from the server
We are going to write all the loading functions in the `AppDelegate` this is good practice so that we can access these functions throughout the app.

In the `AppDelegate.h` add  `#define BASE_URL @"http://localhost:8888"` this will save us from having to type this a bunch and easy to set for production.

**Singleton AppDelegate**
This is a nice helper function to get the `AppDelegate` instance. Create this static method.

**AppDelegate.h**
`+(AppDelegate*)getInstance;`

**Load Notes**
```
+(AppDelegate*)getInstance {
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}
```

We can now call this simply by typing `[AppDelegate getInstance]`

Lets make a function that will load any url with a method. 
in your `AppDelegate.h` add this function.
`-(void)makeRequest:(NSString*)urlString method:(NSString*)method;`

in `AppDelegate.m`
```
-(void)makeRequest:(NSString *)urlString method:(NSString *)method {
    
    // create the url
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASE_URL, urlString]];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    // set the method (GET/POST/PUT/UPDATE/DELETE)
    [request setHTTPMethod:method];
    
    // submit the request
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

                               // do we have data?
                               if(data && data.length > 0) {
                                   
                                   NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                   NSLog(@"json %@", json);
                               }
                               
                           }];
    
}
```

Now lets test this function. In `AppDelegate.m` `didFinishLaunchingWithOptions` add the function to load all the notes.

`[self makeRequest:@"notes" method:@"GET"];`

Run & Build. You will see output in the console of the a `NSDictionary` of all the notes. 

# Requesting Data Delegate
This request is happening  [asynchronously](https://www.google.com/webhp?sourceid=chrome-instant&ion=1&espv=2&ie=UTF-8#q=define+asynchronous+loading). We need a way to know that the data has finished loading. Lets create a delegate for making a request.
 
At the top of the `AppDelegate.h` file create a `@protocol` called `RequestDelegate`.

```
@protocol RequestDelegate <NSObject>
@optional
-(void)didFinishRequestingData:(NSDictionary*)data;
@end
```

We created a optional method that we can listen to. It will pass us a `NSDictionary` of the data when the request is finished.

Add a `delegate` property to the `AppDelegate` and `@synthesize` it.

In AppDelegate.h
`@property (strong, nonatomic) id <RequestDelegate> delegate;`

In AppDelegate.m
`@synthesize delegate;`

In `AppDelegate.m` we need to execute this function when the request is finished.  
The `makeRequest` should look like this now.

```
-(void)makeRequest:(NSString *)urlString method:(NSString *)method {
    
    // create the url
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASE_URL, urlString]];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    // set the method (GET/POST/PUT/UPDATE/DELETE)
    [request setHTTPMethod:method];
    
    // submit the request
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

                               // do we have data?
                               if(data && data.length > 0) {
                                   
                                   NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                   
                                   if(delegate && [delegate respondsToSelector:@selector(didFinishRequestingData:)]) {
                                       [delegate performSelector:@selector(didFinishRequestingData:) withObject:json];
                                   }
                                   
                               }
                               
                           }];
    
}
```

# Connect Notes Controller
Click on the `NotesController.h` and first include the `AppDelegate.h` at the top of the file.

Add the `RequestDelegate` to the `NotesController` .

**NotesController.h**
```
#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface NotesController : UITableViewController <RequestDelegate>

@end
```
Add the `didFinishedRequestingData` to the class and tell the `AppDelegate` that this class is the `RequestDelegate`.
**NotesController.m**
```
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AppDelegate getInstance].delegate = self;
}

-(void)didFinishRequestingData:(NSDictionary *)data {
    
}

```










