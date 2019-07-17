//
//  AlertViewController.h
//  ARTest2
//
//  Created by SOMEI Yoshino on 2019/07/17.
//  Copyright © 2019 sphear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlertViewController : NSObject

@property (nonatomic, weak) ViewController *viewController;

- (void)showUnsupportedAlert;
- (void)showOverlyText:(NSString *)text withDuration:(int)duration;
- (void)showPermissionAlertWithDescription:(NSString *)accessDescription;

@end

NS_ASSUME_NONNULL_END
