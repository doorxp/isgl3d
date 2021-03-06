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

#import "FollowCameraTestView.h"
#import "Isgl3dFollowCamera.h"


@interface FollowCameraTestView () {
@private
	Isgl3dNode * _container;
	Isgl3dMeshNode * _sphere;
	
	id<Isgl3dCamera>  _staticCamera;
	Isgl3dFollowCamera * _followCamera;
	
	float _angle;
}
- (Isgl3dFollowCamera *)createFollowCameraForTarget:(Isgl3dNode *)target;
@end


@implementation FollowCameraTestView

- (id)init {
	
	if ((self = [super init])) {
		_angle = 0.0f;

		// Enable shadows
		[Isgl3dDirector sharedInstance].shadowRenderingMethod = Isgl3dShadowPlanar;
		[Isgl3dDirector sharedInstance].shadowAlpha = 0.5;
		
		// Keep a reference to the default camera and move it
        _staticCamera = [self.camera retain];
		_staticCamera.eyePosition = Isgl3dVector3Make(0.0f, 14.0f, 20.0f);
        
		// Create the ground surface
		Isgl3dTextureMaterial * woodMaterial = [Isgl3dTextureMaterial materialWithTextureFile:@"wood.png" shininess:0.9 precision:Isgl3dTexturePrecisionMedium repeatX:NO repeatY:NO];
		Isgl3dPlane * planeMesh = [Isgl3dPlane meshWithGeometry:20.0 height:20.0 nx:10 ny:10];
		Isgl3dMeshNode * plane = [self.scene createNodeWithMesh:planeMesh andMaterial:woodMaterial];
		plane.rotationX = -90.0f;

		// Create container		
		_container = [self.scene createNode]; 
		_container.position = Isgl3dVector3Make(0.0f, 2.0f, 0.0f);
		
		// Create ball
		Isgl3dTextureMaterial * checkerMaterial = [Isgl3dTextureMaterial materialWithTextureFile:@"red_checker.png" shininess:0.9 precision:Isgl3dTexturePrecisionMedium repeatX:NO repeatY:NO];
		Isgl3dSphere * sphereMesh = [Isgl3dSphere meshWithGeometry:1.0 longs:10 lats:10];
		_sphere = [_container createNodeWithMesh:sphereMesh andMaterial:checkerMaterial];
		_sphere.position = Isgl3dVector3Make(7.0f, 0.0f, 0.0f);
		_sphere.enableShadowCasting = YES;
		
		// Create follow camera
 		_followCamera = [[self createFollowCameraForTarget:_sphere] retain];
		_followCamera.stiffness = 60.0f;
		_followCamera.damping = 50.0f;
		_followCamera.lookAhead = 1.0f;
		[self.scene addChild:_followCamera];
		
		// Create sphere (to represent camera)
		Isgl3dColorMaterial * coneMaterial = [Isgl3dColorMaterial materialWithHexColors:@"444444" diffuse:@"888888" specular:@"ffffff" shininess:0.0];
		Isgl3dMeshNode * cone = [_followCamera createNodeWithMesh:sphereMesh andMaterial:coneMaterial];
		[cone setScale:0.2];
		
		// Add light
		Isgl3dShadowCastingLight * light  = [Isgl3dShadowCastingLight lightWithHexColor:@"FFFFFF" diffuseColor:@"FFFFFF" specularColor:@"FFFFFF" attenuation:0.005];
		light.position = Isgl3dVector3Make(5.0f, 15.0f, 5.0f);
		light.planarShadowsNode = plane;
		[self.scene addChild:light];
		
		// Schedule updates
		[self schedule:@selector(tick:)];
	}
	
	return self;
}

- (void)dealloc {
    [_staticCamera release];
    _staticCamera = nil;
	[_followCamera release];
    _followCamera = nil;
	
	[super dealloc];
}

- (Isgl3dFollowCamera *)createFollowCameraForTarget:(Isgl3dNode *)target {
    float fovyRadians = Isgl3dMathDegreesToRadians(45.0f);
    Isgl3dVector3 cameraPosition = Isgl3dVector3Make(0.0f, 0.0f, 10.0f);
    Isgl3dVector3 cameraUp = Isgl3dVector3Make(0.0f, 1.0f, 0.0f);
    
    Isgl3dPerspectiveProjection *perspectiveLens = [[Isgl3dPerspectiveProjection alloc] initFromViewSize:self.viewport.size fovyRadians:fovyRadians nearZ:1.0f farZ:10000.0f];
    Isgl3dFollowCamera *camera = [[[Isgl3dFollowCamera alloc] initWithLens:perspectiveLens position:cameraPosition andTarget:target up:cameraUp] autorelease];
    [camera.lens viewSizeUpdated:self.viewport.size];
    [perspectiveLens release];
    
    return camera;
}

- (void)setViewport:(CGRect)viewport {
    [super setViewport:viewport];
    
	if (_followCamera) {
        [_followCamera.lens viewSizeUpdated:viewport.size];
	}	
}

- (void)onActivated {
	[[Isgl3dTouchScreen sharedInstance] addResponder:self];
}

- (void)onDeactivated {
	[[Isgl3dTouchScreen sharedInstance] removeResponder:self];
}

- (void)tick:(float)dt {
	_angle += 1.0f;
	_container.rotationY = _angle;
	_sphere.rotationX -= 4.0f;
	_sphere.y = sin(8.0f * Isgl3dMathDegreesToRadians(_angle));
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (self.camera == _staticCamera) {
		self.camera = _followCamera;
	} else {
		self.camera = _staticCamera;
	}
	
} 

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}


@end


#pragma mark SimpleUIView


@implementation SimpleUIView

- (id)init {
	
	if ((self = [super init])) {
		Isgl3dGLUILabel * label = [[Isgl3dGLUILabel alloc] initWithText:@"Click to change camera" fontName:@"Helvetica" fontSize:24];
		[label setX:100 andY:8];
		label.transparent = YES;
		[self.scene addChild:label];
        [label release];
	}
	
	return self;
}

- (void)dealloc {

	[super dealloc];
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
	[[Isgl3dDirector sharedInstance] addView:[FollowCameraTestView view]];
	[[Isgl3dDirector sharedInstance] addView:[SimpleUIView view]];
}

@end
