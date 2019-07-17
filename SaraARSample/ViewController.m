//
//  ViewController.m
//  SaraARSample
//
//  Created by SOMEI Yoshino on 2019/07/17.
//  Copyright © 2019 sphear. All rights reserved.
//

#import "ViewController.h"
#import "AlertViewController.h"
#import "ARSCNViewController.h"

@interface ViewController ()

@property (nonatomic, strong) AlertViewController *alertController;
@property (nonatomic, strong) ARSCNViewController *sceneController;
// アニメ用配列
@property (nonatomic, retain) NSMutableArray *animeArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialGetter];
    [self setupScene];
    [self setupGestureRecognizer];
    [self setupAnimation];
}

- (void)viewWillAppear:(BOOL)animated {
    if (ARWorldTrackingConfiguration.isSupported) {
        NSLog(@"AR World Tracking supported!");
        [self startSession];
        
    } else {
        NSLog(@"No supported AR World Tracking...");
        [self.alertController showUnsupportedAlert];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.sceneView.session pause];
}
- (void)didReceiveMemoryWarning { [super didReceiveMemoryWarning]; }

// ------------------------------------------------------------------------------------
// ARセッション開始！
- (void)startSession {
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
    configuration.planeDetection = ARPlaneDetectionHorizontal; // 水平面検知
    [self.sceneView.session runWithConfiguration:configuration];
    
    [self checkMediaPermission];
}

- (void)refreshSession {
    for (SCNNode *node in self.sceneNode) {
        NSLog(@"refresh session");
        [node removeFromParentNode];
    }
    
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
    configuration.planeDetection = ARPlaneDetectionHorizontal;
    [self.sceneView.session runWithConfiguration:configuration options:ARSessionRunOptionResetTracking | ARSessionRunOptionRemoveExistingAnchors];
    
    [self checkMediaPermission];
}

// カメラ使用許可チェック
- (void)checkMediaPermission {
    dispatch_async(dispatch_get_main_queue(), ^{
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusAuthorized || status == AVAuthorizationStatusNotDetermined) {
            NSLog(@"starting a new session, tyr moving left or right.");
            [self.alertController showOverlyText:@"Starting a new session, try moving left or right" withDuration:2];
        } else {
            NSString *description = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSCameraUsageDescription"];
            NSLog(@"%@", description);
            [self.alertController showPermissionAlertWithDescription:description];
        }
    });
}

// --------------------------------------------------------------------------------------------------
// アラートクラス、ジェスチャークラスを設定
- (void)initialGetter {
    if(!self.alertController){
        self.alertController = [[AlertViewController alloc] init];
        self.alertController.viewController = self;
    }
    if(!self.sceneController){
        self.sceneController = [[ARSCNViewController alloc] init];
        self.sceneController.nodecnt = 0;
        self.sceneController.viewController = self;
        self.sceneController.alertController = self.alertController;
    }
}
// シーンを作成、3Dとか2Dのオブジェクトはこのシーンに貼り付けます。
- (void)setupScene {
    self.sceneView.delegate = self.sceneController;
    self.sceneNode = [NSMutableArray new];
    self.sceneView.showsStatistics = YES;
    self.sceneView.autoenablesDefaultLighting = YES;
    self.sceneView.debugOptions = SCNDebugOptionNone;
    //self.sceneView.debugOptions = ARSCNDebugOptionShowWorldOrigin | ARSCNDebugOptionShowFeaturePoints;
    
    SCNScene *scene = [SCNScene new];
    self.sceneView.scene = scene;
}

// --------------------------------------------------------------------------------------------------
// set gesture
// タップジェスチャーを設定します
- (void)setupGestureRecognizer {
    // tap gesture
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapScreen:)];
    tapGesture.numberOfTapsRequired = 1;
    [self.sceneView addGestureRecognizer:tapGesture];
    
    // long press gesture
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressScreen:)];
    longPress.minimumPressDuration = 0.5;
    [self.sceneView addGestureRecognizer:longPress];
}

// タップされたときに呼び出される関数
- (void)handleTapScreen:(UITapGestureRecognizer *)recognizer {
    CGPoint tapPoint = [recognizer locationInView:self.sceneView];
    NSArray <SCNHitTestResult *>*result = [self.sceneView hitTest:tapPoint options:@{SCNHitTestBoundingBoxOnlyKey: @YES, SCNHitTestFirstFoundOnlyKey: @YES}];
    if(result.count == 0){
        NSLog(@"new tap!");
    } else {
        SCNHitTestResult *tres = [result firstObject];
        //NSLog(@"name: %@", tres.node.name);
        NSLog(@"taps: x: %f  y: %f  z: %f", tres.worldCoordinates.x, tres.worldCoordinates.y, tres.worldCoordinates.z);
        
        SCNNode *node = [self animatedCircle:tres.node];
        [tres.node addChildNode:node];
    }
}

// ロングプレスしたときに呼び出される関数
- (void)handleLongPressScreen:(UILongPressGestureRecognizer *)recognizer {
    CGPoint pressPoint = [recognizer locationInView:self.sceneView];
    NSArray <SCNHitTestResult *>*result = [self.sceneView hitTest:pressPoint options:@{SCNHitTestBoundingBoxOnlyKey: @YES, SCNHitTestFirstFoundOnlyKey: @YES}];
    
    switch(recognizer.state){
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan:
            if(result.count == 0){
                NSLog(@"new press!");
            } else {
                SCNHitTestResult *tres = [result firstObject];
                NSLog(@"press: x: %f  y: %f  z: %f", tres.worldCoordinates.x, tres.worldCoordinates.y, tres.worldCoordinates.z);
                
                SCNNode *node = [self animatedBox:tres.node];
                [tres.node addChildNode:node];
            }
            break;
        case UIGestureRecognizerStateChanged:
            break;
        case UIGestureRecognizerStateEnded:
            break;
        case UIGestureRecognizerStateCancelled:
            break;
        case UIGestureRecognizerStateFailed:
            break;
    }
}

// --------------------------------------------------------------------------------------------------
// アニメーション付き円
- (SCNNode *)animatedCircle:(SCNNode *)node {
    SCNMaterial *material = [SCNMaterial new];
    material.diffuse.contents = [self create2DCircleWithAnime:node];
    
    SCNPlane *pln = [SCNPlane planeWithWidth:2.0 height:2.0];
    pln.materials = @[material];
    SCNNode *pnode = [SCNNode nodeWithGeometry:pln];
    return pnode;
}

- (UIImageView *)create2DCircleWithAnime:(SCNNode *)node {
    NSMutableArray *iary = [[NSMutableArray alloc] init];
    [iary removeAllObjects];
    for(int i = 0; i < 15; i++){
        float rad = (150.0 / 15) * (i + 1);
        UIImage *img = [self circleImg:rad];
        [iary addObject:img];
    }
    UIImage *animeImg = [UIImage animatedImageWithImages:iary duration:0.75];
    UIImageView *imgview = [[UIImageView alloc] initWithImage:animeImg];
    imgview.animationDuration = 1.0;
    imgview.animationRepeatCount = 1; //INFINITY;
    [self performSelector:@selector(animationDidFinish:) withObject:node afterDelay:0.75];
    return imgview;
}
- (void)animationDidFinish:(id)sender {
    NSLog(@"animation did finish");
    SCNNode *node = (SCNNode *)sender;
    [node.childNodes.firstObject removeFromParentNode];
}

// 円を描く
- (UIImage *)circleImg:(float)radius {
    // 描画用イメージ作成
    CGRect rect = CGRectMake(0, 0, 300.0, 300.0); // unit -> pixel
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //UIGraphicsPushContext(context);
    
    // 描画！
    UIBezierPath *circle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(150.0, 270.0) radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
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

// -------------------------------------------------------------------------------------
// アニメーション付きボックス
- (SCNNode *)animatedBox:(SCNNode *)node {
    SCNMaterial *material = [SCNMaterial new];
    material.diffuse.contents = [self create2DBoxWithAnime:node];
    
    SCNPlane *pln = [SCNPlane planeWithWidth:2.0 height:2.0];
    pln.materials = @[material];
    SCNNode *pnode = [SCNNode nodeWithGeometry:pln];
    return pnode;
}

- (UIImageView *)create2DBoxWithAnime:(SCNNode *)node {
    NSMutableArray *iary = [[NSMutableArray alloc] init];
    [iary removeAllObjects];
    
    [iary addObjectsFromArray:_animeArray];
    
    UIImage *animeImg = [UIImage animatedImageWithImages:iary duration:2.25];
    UIImageView *imgview = [[UIImageView alloc] initWithImage:animeImg];
    imgview.animationDuration = 1.0;
    imgview.animationRepeatCount = 1; //INFINITY;
    [self performSelector:@selector(animationDidFinish:) withObject:node afterDelay:2.25];
    return imgview;
}

// -------------------------------------------------------------------------------------
// ボックスのアニメーションは作成に時間がかかるので、起動時に作成しておきます。
//  kira-kira animeation! :p
- (void)setupAnimation {
    NSMutableArray *anime = [[NSMutableArray alloc] init];
    [anime removeAllObjects];
    
    NSArray *patAry = [self createLightPointMatrix];
    for(int i = 0; i < 2; i++){
        NSMutableArray *aniary = [self kiraAnimeImgs:patAry];
        [anime addObjectsFromArray:aniary];
    }
    NSMutableArray *aniary2 = [self flowAnimeImgs:patAry];
    [anime addObjectsFromArray:aniary2];
    
    _animeArray = [[NSMutableArray alloc] initWithArray:anime];
}

// あるエリアに上述４パターンの小さいボックスを配置（ランダムで）、配列を返す
- (NSArray *)createLightPointMatrix {
    int colmax = 24, rowmax = 24;
    NSArray *patary = @[@0, @0, @0, @0, @1, @1, @1, @2, @2, @3];
    NSMutableArray *pary = [[NSMutableArray alloc] init];
    for(int r = 0; r < rowmax; r++){
        NSMutableArray *cary = [[NSMutableArray alloc] init];
        for(int c = 0; c < colmax; c++){
            int pat = (int)arc4random_uniform(10);
            //NSLog(@"pat: %d  -> patary: %@", pat, [patary objectAtIndex:pat]);
            [cary addObject:[NSNumber numberWithInt:[[patary objectAtIndex:pat] intValue]]];
        }
        [pary addObject:cary];
    }
    return pary;
}

// 配列で与えられた４パターンのボックスをここで描画！
- (UIImage *)createBoxWall:(NSArray *)patternArray {
    // 描画用イメージ作成
    CGRect rect = CGRectMake(0, 0, 300.0, 300.0); // unit -> pixel
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //UIGraphicsPushContext(context);
    
    float blocksize = 8;
    // 描画！
    UIBezierPath *boxs = [UIBezierPath bezierPath];
    for(int y = 0; y < 24; y++){
        for(int x = 0; x < 24; x++){
            float sx, sy;
            sx = (x + 1) * (blocksize * 1.5);
            sy = (y + 1) * (blocksize * 1.5);
            int pat = [[[patternArray objectAtIndex:y] objectAtIndex:x] intValue];
            //NSLog(@"y: %d  x: %d  pat: %d", y, x, pat);
            boxs = [self drawRect:boxs pattern:pat position_x:sx position_y:sy];
        }
    }
    // 描いた絵を UIImage に変換（描画用イメージを終了）
    CGContextAddPath(context, boxs.CGPath);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    //UIGraphicsPopContext();
    UIGraphicsEndImageContext();
    
    return img;
}

// 実際の描画はここ。四角を描くよ（ラインをつないで描くよバージョン）
//    pattern: 0 empty, 1 dot, 2 small rect, 3 large rect
- (UIBezierPath *)drawRect:(UIBezierPath *)boxs pattern:(int)pattern position_x:(float)posx position_y:(float)posy {
    if(pattern == 0) return boxs;
    
    int w = 1;
    if(pattern == 1) w = 1;
    if(pattern == 2) w = 2;
    if(pattern == 3) w = 3;
    [boxs moveToPoint:CGPointMake(posx - w, posy - w)];
    [boxs addLineToPoint:CGPointMake(posx + w, posy - w)];
    [boxs addLineToPoint:CGPointMake(posx + w, posy + w)];
    [boxs addLineToPoint:CGPointMake(posx - w, posy + w)];
    [boxs closePath];
    [[UIColor whiteColor] setFill];
    [boxs fill];
    [[UIColor whiteColor] setStroke];
    boxs.lineWidth = 1.0;
    [boxs stroke];
    return boxs;
}

// キラキラアニメーションを作成。
- (NSMutableArray *)kiraAnimeImgs:(NSArray *)lightPointMatrix {
    NSMutableArray *aniImgArray = [[NSMutableArray alloc] init];
    [aniImgArray removeAllObjects];
    
    // copy from matrix
    NSMutableArray *aniMatrix = [[NSMutableArray alloc] initWithArray:lightPointMatrix];
    for(int f = 0; f < 5; f++){
        // calculate point-matrix
        for(int r = 0; r < 24; r++){
            for(int c = 0; c < 24; c++){
                int nval = [[[aniMatrix objectAtIndex:r] objectAtIndex:c] intValue];
                nval -= 1;
                if(nval < 0) nval = 3;
                [[aniMatrix objectAtIndex:r] replaceObjectAtIndex:c withObject:[NSNumber numberWithInt:nval]];
            }
        }
        // drawing!
        UIImage *img = [self createBoxWall:aniMatrix];
        [aniImgArray addObject:img];
    }
    return aniImgArray;
}

// 上に流れるアニメーションを作成。
- (NSMutableArray *)flowAnimeImgs:(NSArray *)lightPointMatrix {
    NSMutableArray *aniImgArray = [[NSMutableArray alloc] init];
    [aniImgArray removeAllObjects];
    
    // flowing matrix
    NSMutableArray *aniMatrix = [[NSMutableArray alloc] initWithArray:lightPointMatrix];
    for(int f = 0; f < 27; f++){
        // calculate point-matrix
        for(int r = 1; r < 25; r++){
            for(int c = 0; c < 24; c++){
                int pval = 0;
                if(r < 25) pval = [[[aniMatrix objectAtIndex:(r -1)] objectAtIndex:c] intValue] - 1;
                if(pval < 0) pval = 0;
                
                int nval = 0;
                if(r < 24) nval = [[[aniMatrix objectAtIndex:r] objectAtIndex:c] intValue];
                
                if(nval < pval) nval += pval;
                if(nval > 3) nval = 3;
                [[aniMatrix objectAtIndex:(r - 1)] replaceObjectAtIndex:c withObject:[NSNumber numberWithInt:nval]];
            }
        }
        // drawing!
        UIImage *img = [self createBoxWall:aniMatrix];
        [aniImgArray addObject:img];
    }
    return aniImgArray;
}

@end
