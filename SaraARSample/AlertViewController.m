//
//  AlertViewController.m
//  ARTest2
//
//  Created by SOMEI Yoshino on 2019/07/17.
//  Copyright © 2019 sphear. All rights reserved.
//

#import "AlertViewController.h"

@interface AlertViewController ()
@end

@implementation AlertViewController

- (void)showUnsupportedAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unsupported platform" message:@"This app requires world tracking. World tracking is only available on iOS11 with A9 processor devices or newer" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
    [alert addAction:noAction];
    [self.viewController presentViewController:alert animated:YES completion:nil];
}

- (void)showOverlyText:(NSString *)text withDuration:(int)duration {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:text preferredStyle:UIAlertControllerStyleAlert];
    [self.viewController presentViewController:alert animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)showPermissionAlertWithDescription:(NSString *)accessDescription {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:accessDescription message:@"To give permission tap on 'Change Settings' button." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Change Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    }];
    [alert addAction:settingsAction];
    [self.viewController presentViewController:alert animated:YES completion:nil];
}

@end
