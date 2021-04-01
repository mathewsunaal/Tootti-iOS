//
//  SignupViewController.m
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-02-23.
//

#import "SignupViewController.h"
#import "ToottiDefinitions.h"
@import Firebase;

@interface SignupViewController () <UITextFieldDelegate>

@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *pass;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *bio;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;
@property bool isUp;
@property (nonatomic, readwrite) FIRFirestore *db;
@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set delegates
    self.emailTextField.delegate = self;
    self.passTextField.delegate = self;
    self.usernameTextField.delegate = self;
    self.instrumentTextField.delegate = self;
    self.isUp = false;
    self.db =  [FIRFirestore firestore];
    [self setupViews];
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

//Refocus the keyboard
-(void)textFieldDidBeginEditing
{
    if (self.isUp != true){
        [self animateUp:YES];
    }
}

- (void)textFieldDidEndEditing
{
    NSLog(self.isUp ? @"EndCalling YES": @"EndCalling NO");
    if (self.isUp == true){
        [self animateUp:NO];
    }
}
-(void)animateUp:(BOOL)up
{
    const int movementDistance = -130; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    self.isUp = (up ? true : false);
    int movement = (up ? movementDistance : -movementDistance);
    //Need to update this part
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (void) setupViews {
    
    // Set background colour of view controller
    [self.view setBackgroundColor: BACKGROUND_LIGHT_TEAL];
    // Set up logo image
    self.logoImageView.image = [UIImage imageNamed:@"app-logo"];
    [self.errorMessage setHidden: TRUE];
    // Setup buttons
    self.createAccountButton.backgroundColor = BUTTON_DARK_TEAL;
    self.createAccountButton.layer.cornerRadius = NORMAL_BUTTON_CORNER_RADIUS;
    self.createAccountButton.clipsToBounds = YES;
    [self.createAccountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.createAccountButton.titleLabel setFont:[UIFont fontWithName:NORMAL_BUTTON_FONT_TYPE size:NORMAL_BUTTON_FONT_SIZE]];
    
}


- (IBAction)createAccount:(UIButton *)sender {
    
    self.email = self.emailTextField.text;
    self.pass = self.passTextField.text;
    self.username = self.usernameTextField.text;
    self.bio = self.instrumentTextField.text;
    
    NSLog(@"Create Account Request");

    // Firebase call to create new user ...
    
    
    
    
    [[FIRAuth auth] createUserWithEmail:self.email
                               password:self.pass
                             completion:^(FIRAuthDataResult * _Nullable authResult,
                                          NSError * _Nullable error) {
        if (error){
            NSLog(@"Something is wrong!!!!!!!!!!!!");
            NSLog(@"%@", error.localizedDescription);
            [self.errorMessage setText: error.localizedDescription];
            [self.errorMessage setHidden: FALSE];
        }
        else{
            NSDictionary *docData = @{
                @"email": self.email,
                @"instrument": self.bio,
                @"user": self.username,
                @"allMergedSongs": [NSMutableArray new],
                @"joinedSessions": [NSMutableArray new]
            };
            NSLog(@"%@", docData);
            __block FIRDocumentReference *ref =
                [[self.db collectionWithPath:@"user"] addDocumentWithData:docData completion:^(NSError * _Nullable error) {
                  if (error != nil) {
                    NSLog(@"Error adding document: %@", error);
                  } else {
                    NSLog(@"Document added with ID: %@", ref.documentID);
                  }
                }];
            [self performSegueWithIdentifier:@"showLogInSegue" sender:self];
        }
    }];
}

// Textfield delegate methods

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return TRUE;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
