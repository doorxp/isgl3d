/*
 * iSGL3D: http://isgl3d.com
 *
 * Copyright (c) 2010-2012 Stuart Caunt
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "KeyframeMeshAnimationTestView.h"
#import "TestMesh.h"
#import "Isgl3dDemoCameraController.h"


@interface KeyframeMeshAnimationTestView () {
@private
    Isgl3dNodeCamera *_camera;
}
@property (nonatomic,retain) Isgl3dNodeCamera *camera;
@end


#pragma mark -
@implementation KeyframeMeshAnimationTestView

@synthesize camera = _camera;

- (id)init {
	
	if (self = [super init]) {
		
		// Create and configure touch-screen camera controller
		_cameraController = [[Isgl3dDemoCameraController alloc] initWithNodeCamera:self.camera andView:self];
		_cameraController.orbit = 7;
		_cameraController.theta = 0;
		_cameraController.phi = 30;
		_cameraController.doubleTapEnabled = NO;

		// Create meshes needed for animation 
		TestMesh * mesh1 = [[TestMesh alloc] initWithGeometry:5.0f length:5.0f height:0.5f nx:32 ny:32 factor:1.0f];
		TestMesh * mesh2 = [[TestMesh alloc] initWithGeometry:5.0f length:5.0f height:0.5f nx:32 ny:32 factor:-1.0f];
		
		// Create animated keyframe mesh
		_mesh = [Isgl3dKeyframeMesh keyframeMeshWithMesh:mesh1];
		[_mesh addKeyframeMesh:mesh2];
		
		// Set up animation data
		[_mesh addKeyframeAnimationData:0 duration:2.0f];
		[_mesh addKeyframeAnimationData:1 duration:1.0f];
		
		// Start the automatic mesh animation
		[_mesh startAnimation];
		
		Isgl3dTextureMaterial * material = [Isgl3dTextureMaterial materialWithTextureFile:@"ground.png" shininess:0.9 precision:Isgl3dTexturePrecisionLow repeatX:NO repeatY:NO];
		[self.scene createNodeWithMesh:_mesh andMaterial:material];

		// Add light to scene
		Isgl3dLight * light  = [Isgl3dLight lightWithHexColor:@"222222" diffuseColor:@"FFFFFF" specularColor:@"FFFFFF" attenuation:0.005];
		light.position = Isgl3dVector3Make(3, 2, 3);
		[self.scene addChild:light];

		// Schedule updates
		[self schedule:@selector(tick:)];
        
        [mesh1 release];
        [mesh2 release];
	}
	
	return self;
}

- (void)dealloc {
	[_cameraController release];
    _cameraController = nil;

	[super dealloc];
}


- (void)createSceneCamera {
    CGSize viewSize = self.viewport.size;
    float fovyRadians = Isgl3dMathDegreesToRadians(45.0f);
    Isgl3dPerspectiveProjection *perspectiveLens = [[Isgl3dPerspectiveProjection alloc] initFromViewSize:viewSize fovyRadians:fovyRadians nearZ:1.0f farZ:10000.0f];
    
    Isgl3dVector3 cameraPosition = Isgl3dVector3Make(0.0f, 0.0f, 10.0f);
    Isgl3dVector3 cameraLookAt = Isgl3dVector3Make(0.0f, 0.0f, 0.0f);
    Isgl3dVector3 cameraLookUp = Isgl3dVector3Make(0.0f, 1.0f, 0.0f);
    Isgl3dNodeCamera *standardCamera = [[Isgl3dNodeCamera alloc] initWithLens:perspectiveLens position:cameraPosition lookAtTarget:cameraLookAt up:cameraLookUp];
    [perspectiveLens release];
    
    self.camera = standardCamera;
    [standardCamera release];
    [self.scene addChild:standardCamera];
}

- (void)onActivated {
	// Add camera controller to touch-screen manager
	[[Isgl3dTouchScreen sharedInstance] addResponder:_cameraController];
}

- (void)onDeactivated {
	// Remove camera controller from touch-screen manager
	[[Isgl3dTouchScreen sharedInstance] removeResponder:_cameraController];
}

- (void)tick:(float)dt {
	// update camera
	[_cameraController update];
}


@end



#pragma mark AppDelegate

/*
 * Implement principal class: simply override the createViews method to return the desired demo view.
 */
@implementation AppDelegate

- (void)createViews {
	// Set the device orientation
	[Isgl3dDirector sharedInstance].deviceOrientation = Isgl3dOrientationLandscapeLeft;

	// Create view and add to Isgl3dDirector
	Isgl3dView * view = [KeyframeMeshAnimationTestView view];
	[[Isgl3dDirector sharedInstance] addView:view];
}

@end
