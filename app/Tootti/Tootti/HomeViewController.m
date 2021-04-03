//
//  ViewController.m
//  Tootti
//
//  Created by Hanyu Xi on 2021-02-11.
//

#import "HomeViewController.h"
#import "HomeSessionVC.h"
#import "ToottiDefinitions.h"
#include "User.h"

@import Firebase;
@interface HomeViewController ()
@property(strong, nonatomic) FIRAuthStateDidChangeListenerHandle handle;
@property(strong, nonatomic) FIRFirestore *db;
@end

@implementation HomeViewController
//define the static variable
User *user = nil;
bool isUp= false;
//Refocus the keyboard
-(void)textFieldDidBeginEditing
{
    if (isUp != true){
        [self animateUp:YES];
    }
}

- (void)textFieldDidEndEditing
{
    NSLog(isUp ? @"EndCalling YES": @"EndCalling NO");
    if (isUp == true){
        [self animateUp:NO];
    }
}
-(void)animateUp:(BOOL)up
{
    const int movementDistance = -130; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    isUp = (up ? true : false);
    int movement = (up ? movementDistance : -movementDistance);
    //Need to update this part
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.db = [FIRFirestore firestore];
    // Set delegates
    self.emailTextField.delegate = self;
    self.passTextField.delegate = self;
    //[FIRApp configure];
    [self setupViews];
    
    //keyboardIsShown = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidBeginEditing)
                                             name:UIKeyboardWillShowNotification
                                           object:self.view.window];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidEndEditing)
                                             name:UIKeyboardWillHideNotification
                                           object:self.view.window];
    
    NSString *savedUid = [[NSUserDefaults standardUserDefaults]
        stringForKey:@"uid"];
    NSString *savedEmail = [[NSUserDefaults standardUserDefaults]
        stringForKey:@"email"];
    NSString *savedUsername = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];

    //Fetch all user information from database and initialize the user instance
    if ( savedUid != nil){
    [[[self.db collectionWithPath:@"user"] queryWhereField:@"email" isEqualTo: savedEmail]
        getDocumentsWithCompletion:^(FIRQuerySnapshot *snapshot, NSError *error) {
          if (error != nil) {
            NSLog(@"Error getting documents: %@", error);
          } else {
              FIRDocumentSnapshot *document = snapshot.documents[0];
              user = [[User alloc] initWithUid: document.documentID email: savedEmail username: savedUsername instrument:document.data[@"instrument"]  joinedSessions: document.data[@"joinedSessions"] allMergedSongs: document.data[@"allMergedSongs"]];
              [self performSegueWithIdentifier:@"loginUser" sender:self];
          }
        }];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[[FIRAuth auth] removeAuthStateDidChangeListener:_handle];
    // unregister for keyboard notifications while not visible.
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void) setupViews {
    
    // Set background colour of view controller
    [self.view setBackgroundColor: BACKGROUND_LIGHT_TEAL];
    // Setup home logo
    self.logoImageView.image = [UIImage imageNamed:@"home-logo"];
    
    // Setup buttons
    self.loginButton.backgroundColor = BUTTON_DARK_TEAL;
    self.loginButton.layer.cornerRadius = NORMAL_BUTTON_CORNER_RADIUS;
    self.loginButton.clipsToBounds = YES;
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.loginButton.titleLabel setFont:[UIFont fontWithName:NORMAL_BUTTON_FONT_TYPE size:NORMAL_BUTTON_FONT_SIZE]];
    
    self.signupButton.backgroundColor = BUTTON_DARK_TEAL;
    self.signupButton.layer.cornerRadius = NORMAL_BUTTON_CORNER_RADIUS;
    self.signupButton.clipsToBounds = YES;
    [self.signupButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.signupButton.titleLabel setFont:[UIFont fontWithName:NORMAL_BUTTON_FONT_TYPE size:NORMAL_BUTTON_FONT_SIZE]];
    
    [self.errorMessage setHidden: TRUE];
    
}

- (IBAction)login:(UIButton *)sender {
    
    // Update the string properties
    self.email = self.emailTextField.text;
    self.pass = self.passTextField.text;
    
    NSLog(@"Logging In for: %@",self.email);
    
    // Firebase function to login user.. (move seague to success block)
    //Check the email and pass
    [[FIRAuth auth] signInWithEmail:self.email
                           password:self.pass
                         completion:^(FIRAuthDataResult * _Nullable authResult,
                                      NSError * _Nullable error) {
        if (error) {
            NSLog(@"Sign in failed. Error: %@", error.localizedDescription);
            [self.errorMessage setText: error.localizedDescription];
            [self.errorMessage setHidden: FALSE];
        }
        else{
            NSLog(@"%@",authResult);
            // Log into the app
            [[[self.db collectionWithPath:@"user"] queryWhereField:@"email" isEqualTo: self.email]
                getDocumentsWithCompletion:^(FIRQuerySnapshot *snapshot, NSError *error) {
                  if (error != nil) {
                    NSLog(@"Error getting documents: %@", error);
                  } else {
                      FIRDocumentSnapshot *document = snapshot.documents[0];
                      NSLog(@"%@ => %@", document.documentID, document.data);
                      user = [[User alloc] initWithUid: document.documentID email: self.email username: document.data[@"username"] instrument:document.data[@"instrument"] joinedSessions: document.data[@"joinedSessions"] allMergedSongs: document.data[@"allMergedSongs"]];
                      //Archive the user data
                      NSLog(@"%@", user);
                      //UserDefaults -> email, uid
                      [[NSUserDefaults standardUserDefaults] setObject:self.email forKey:@"email"];
                      [[NSUserDefaults standardUserDefaults] setObject:document.documentID forKey:@"uid"];
                      [[NSUserDefaults standardUserDefaults] setObject:document.data[@"username"] forKey:@"username"];
                      [[NSUserDefaults standardUserDefaults] setObject: [NSMutableArray arrayWithArray: document.data[@"joinedSessions"]] forKey:@"joinedSessions"];
                      [[NSUserDefaults standardUserDefaults] synchronize];
                      [self performSegueWithIdentifier:@"loginUser" sender:self];
                      [self.errorMessage setHidden: TRUE];
                  }
                }];
        }
    }];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
        if([segue.identifier isEqualToString:@"loginUser"]){
            //UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
            //HomeSessionVC *controller = [segue destinationViewController];
            UITabBarController *tabar=(UITabBarController*)segue.destinationViewController;
            HomeSessionVC *controller = (HomeSessionVC *) [tabar.viewControllers objectAtIndex:0];
            
            controller.user = user;
        }
    }



- (IBAction)singup:(UIButton *)sender {
    
    [self performSegueWithIdentifier:@"showSignUp" sender:self];
}

//- (IBAction)openSettings:(id)sender {
//
//    [self performSegueWithIdentifier:@"showSettings" sender:self];
//}

// Textfield delegate methods

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return TRUE;
}

@end
