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

#import "LightingDemoView.h"
#import "Isgl3dDemoCameraController.h"


@interface LightingDemoView (){
@private
    Isgl3dNodeCamera *_camera;
}
@property (nonatomic,retain) Isgl3dNodeCamera *camera;
@end


#pragma mark -
@implementation LightingDemoView

@synthesize camera = _camera;

- (id)init {
	
	if ((self = [super init])) {

		// Create and configure touch-screen camera controller
		_cameraController = [[Isgl3dDemoCameraController alloc] initWithNodeCamera:self.camera andView:self];
		_cameraController.orbit = 17;
		_cameraController.theta = 30;
		_cameraController.phi = 10;
		_cameraController.doubleTapEnabled = NO;
		
		_sceneObjects = [[NSMutableArray alloc] init];
		_sphereAngle = 0;
		_lightAngle = 0;

		Isgl3dTextureMaterial *  textureMaterial = [Isgl3dTextureMaterial materialWithTextureFile:@"mars.png" shininess:0.7 precision:Isgl3dTexturePrecisionMedium repeatX:NO repeatY:NO];
		Isgl3dSphere * primitive = [Isgl3dSphere meshWithGeometry:1.3 longs:15 lats:15];
		
		// Create the spheres with texture materials
		for (int k = 0; k < 3; k++) {
			for (int j = 0; j < 3; j++) {
				for (int i = 0; i < 3; i++) {
					Isgl3dMeshNode * node = [self.scene createNodeWithMesh:primitive andMaterial:textureMaterial];
					node.position = Isgl3dVector3Make(((i - 1.0) * 4), ((j - 1.0) * 4), ((k - 1.0) * 4));
	
					[_sceneObjects addObject:node];
				}
			}		
		}		
		
		
		// Create the lights
		_blueLight = [Isgl3dLight lightWithHexColor:@"000011" diffuseColor:@"0000FF" specularColor:@"FFFFFF" attenuation:0.02];
		[self.scene addChild:_blueLight];
		_blueLight.renderLight = YES;
		
		_redLight = [Isgl3dLight lightWithHexColor:@"110000" diffuseColor:@"FF0000" specularColor:@"FFFFFF" attenuation:0.02];
		[self.scene addChild:_redLight];
		_redLight.renderLight = YES;
		
		_greenLight = [Isgl3dLight lightWithHexColor:@"001100" diffuseColor:@"00FF00" specularColor:@"FFFFFF" attenuation:0.02];
		[self.scene addChild:_greenLight];
		_greenLight.renderLight = YES;
		
		_whiteLight = [Isgl3dLight lightWithHexColor:@"111111" diffuseColor:@"FFFFFF" specularColor:@"FFFFFF" attenuation:0.02];
		[self.scene addChild:_whiteLight];
		_whiteLight.renderLight = YES;
		_whiteLight.position = Isgl3dVector3Make(7, 7, 4);
	
		// Set the scene ambient color
		[self setSceneAmbient:@"444444"];
		
		// Schedule updates
		[self schedule:@selector(tick:)];
	}
	
	return self;
}

- (void)dealloc {
	[_cameraController release];
    _cameraController = nil;

	[_sceneObjects release];
    _sceneObjects = nil;
	
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
	
	// Rotate the spheres
	for (int i = 0; i < [_sceneObjects count]; i++) {
		[[_sceneObjects objectAtIndex:i] setRotation:_sphereAngle x:0 y:1 z:0];
	}

	// Move the lights
	float blueAngle = _lightAngle;
	float redAngle = -(blueAngle + 120);
	float greenAngle = redAngle + 12;
	_blueLight.position = Isgl3dVector3Make(7 * sin(blueAngle * M_PI / 90), 7 * cos(blueAngle * M_PI / 90), 7 * cos(blueAngle * M_PI / 180));
	_redLight.position = Isgl3dVector3Make(7 * sin(redAngle * M_PI / 145), 7 * cos(redAngle * M_PI / 145), 7 * cos(redAngle * M_PI / 180));
	_greenLight.position = Isgl3dVector3Make(7 * sin(greenAngle * M_PI / 60), 7 * cos(greenAngle * M_PI / 60), 7 * cos(greenAngle * M_PI / 180));

	_sphereAngle = (_sphereAngle + 2);
	_lightAngle = _lightAngle + 2;

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
	Isgl3dView * view = [LightingDemoView view];
	[[Isgl3dDirector sharedInstance] addView:view];
}

@end
