//
//  ARSCNViewController.m
//  ARTest2
//
//  Created by SOMEI Yoshino on 2019/07/17.
//  Copyright © 2019 sphear. All rights reserved.
//

#import "ARSCNViewController.h"

@interface ARSCNViewController ()
@end

@implementation ARSCNViewController

// --------------------------------------------------------------------------------------------------
// ノードが追加されました。
- (void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    if (![anchor isKindOfClass:[ARPlaneAnchor class]]) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Surface detected!");
        [self.alertController showOverlyText:@"Surface detected!" withDuration:1];
    });
    
    // add empty image :p
    SCNNode *enode = [self cerateEmptyPlane];
    [node addChildNode:enode];
}

- (void)renderer:(id<SCNSceneRenderer>)renderer willUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor { }
- (void)renderer:(id<SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor { }
- (void)renderer:(id<SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor { }

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    NSLog(@"Please try resetting the session");
    [self.alertController showOverlyText:@"Please try resetting the session" withDuration:1];
}
- (void)sessionWasInterrupted:(ARSession *)session {
    NSLog(@"Session interrupted!");
    [self.alertController showOverlyText:@"Session interrupted!" withDuration:1];
}
- (void)sessionInterruptionEnded:(ARSession *)session {
    [self.viewController refreshSession];
}

// --------------------------------------------------------------------------------------------------
// 円を描く
- (UIImage *)circleImg:(float)radius {
    // 描画用イメージ作成
    CGRect rect = CGRectMake(0, 0, 300.0, 300.0); // unit -> pixle
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //UIGraphicsPushContext(context);

    // 描画！
    UIBezierPath *circle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(150.0, 150.0) radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] setStroke];
    [circle setLineWidth:1.0];
    [circle stroke];
    // 描いた絵を UIImage に変換（描画用イメージを終了）
    CGContextAddPath(context, circle.CGPath);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    //UIGraphicsPopContext();
    UIGraphicsEndImageContext();

    return img;
}

// ---------------------------------------------------------------------------------
// 透明Planeを返します。
- (SCNNode *)cerateEmptyPlane {
    UIImage *img = [self circleImg:212.1];
    SCNMaterial *material = [SCNMaterial new];
    material.diffuse.contents = img;
    SCNPlane *pln = [SCNPlane planeWithWidth:2.0 height:2.0];
    pln.materials = @[material];
    SCNNode *node = [SCNNode nodeWithGeometry:pln];
    return node;
}

@end
