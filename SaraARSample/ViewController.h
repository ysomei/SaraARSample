//
//  ViewController.h
//  SaraARSample
//
//  Created by SOMEI Yoshino on 2019/07/17.
//  Copyright © 2019 sphear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ARKit/ARKit.h>
#import <SceneKit/SceneKit.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController

@property (nonatomic, retain) NSMutableArray <SCNNode *>*sceneNode;
@property (nonatomic) NSString *sceneName;

// AR用ビューを定義します。
@property (nonatomic, strong) IBOutlet ARSCNView *sceneView;

// ARセッションのリフレッシュメソッド
- (void)refreshSession;

@end

