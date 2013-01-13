//
//  ViewController.m
//  iossdktest
//
//  Created by Petr Pavlik on 1/13/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <Accounts/Accounts.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)performLogin:(id)sender {
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate openSession];
}

- (IBAction)performTest:(id)sender {
    
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             
             if (error) {
                 NSLog(@"%@", error);
             }
             
             if (!error) {
                 NSLog(@"%@", user.name);
             }
         }];
    }
    
}

- (IBAction)performTest2:(id)sender {
    
    if (FBSession.activeSession.isOpen) {
        
        NSString* address = [NSString stringWithFormat:@"https://graph.facebook.com/1458354903?fields=id,name&access_token=%@", FBSession.activeSession.accessToken];
        
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:address] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:30];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (error) {
                    NSLog(@"%@", error);
                }
                else {
                    NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSLog(@"%@", myString);
                    
                    if ([myString rangeOfString:@"error"].location != NSNotFound) {
                        
                        // Using FBRequest calls internal implementation of renewSystemAuthorization for us. If you decide to not to use FBRequest, you've got handle this yourself using the following code.
                        [FBSession.activeSession closeAndClearTokenInformation];
                        if (FBSession.activeSession.loginType == FBSessionLoginTypeSystemAccount){
                            [self renewSystemAuthorization];
                        }
                    }
                }
                
            });
            
        }];
    }
}

//calls ios6 renewCredentialsForAccount in order to update ios6's worldview of authorization state.
// if not using ios6 system auth, this is a no-op.
- (void)renewSystemAuthorization {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
    
        id accountStore = nil;
        id accountTypeFB = nil;
        
        if ((accountStore = [[ACAccountStore alloc] init]) &&
            (accountTypeFB = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook] ) ){
            
            NSArray *fbAccounts = [accountStore accountsWithAccountType:accountTypeFB];
            id account;
            if (fbAccounts && [fbAccounts count] > 0 &&
                (account = [fbAccounts objectAtIndex:0])){
                
                [accountStore renewCredentialsForAccount:account completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
                    //we don't actually need to inspect renewResult or error.
                    if (error){
                        NSLog(@"%@",error);
                    }
                }];
            }
        }
        
    }
}

@end
