//
//  ARSCNViewController.h
//  ARTest2
//
//  Created by SOMEI Yoshino on 2019/07/17.
//  Copyright © 2019 sphear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"
#import "AlertViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ARSCNViewController : NSObject <ARSCNViewDelegate, ARSessionDelegate>
    
@property (nonatomic, weak) ViewController *viewController;
@property (nonatomic, weak) AlertViewController *alertController;

@property (nonatomic, assign) NSInteger nodecnt;
@property (nonatomic, strong) UIImageView *imgView;

@end

NS_ASSUME_NONNULL_END
