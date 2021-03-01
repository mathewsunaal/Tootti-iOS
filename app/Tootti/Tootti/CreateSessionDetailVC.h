//
//  CreateSessionViewController.h
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-02-28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CreateSessionDetailVC : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *trackLinkTextField;
@property (weak, nonatomic) IBOutlet UITextField *musiciansTextField;
@property (weak, nonatomic) IBOutlet UIButton *createSessionButton;

@end

NS_ASSUME_NONNULL_END