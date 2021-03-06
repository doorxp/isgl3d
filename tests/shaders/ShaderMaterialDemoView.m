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

#import "ShaderMaterialDemoView.h"
#import "Isgl3dDemoCameraController.h"
#import "DemoShader.h"
#import "PowerVRShader.h"


@interface ShaderMaterialDemoView (){
@private
    Isgl3dNodeCamera *_camera;
}
@property (nonatomic,retain) Isgl3dNodeCamera *camera;
@end


#pragma mark -
@implementation ShaderMaterialDemoView

@synthesize camera = _camera;

- (id)init {
	
	if ((self = [super init])) {
		// Create and configure touch-screen camera controller
		_cameraController = [[Isgl3dDemoCameraController alloc] initWithNodeCamera:self.camera andView:self];
		_cameraController.orbit = 17;
		_cameraController.theta = 30;
		_cameraController.phi = 10;
		_cameraController.doubleTapEnabled = NO;

		_container = [[self.scene createNode] retain];
		
		
		// Create custom shader and associate it with a material
		Isgl3dCustomShader * demoShader = [DemoShader shaderWithKey:@"myDemoShader"];
		Isgl3dShaderMaterial * shaderMaterial1 = [Isgl3dShaderMaterial materialWithShader:demoShader];

		Isgl3dCustomShader * powerVRShader = [PowerVRShader shaderWithKey:@"powerVRShader"];
		Isgl3dShaderMaterial * shaderMaterial2 = [Isgl3dShaderMaterial materialWithShader:powerVRShader];

		// Standard material
		Isgl3dTextureMaterial * material = [Isgl3dTextureMaterial materialWithTextureFile:@"red_checker.png" shininess:0.9];
	
		// Apply custom shader material to torus
		Isgl3dTorus * torusMesh = [Isgl3dTorus meshWithGeometry:2 tubeRadius:1 ns:32 nt:32];
		_torus = [_container createNodeWithMesh:torusMesh andMaterial:shaderMaterial1];
		_torus.position = Isgl3dVector3Make(-7, 0, 0);
		_torus.interactive = YES;
		[_torus addEvent3DListener:self method:@selector(objectTouched:) forEventType:TOUCH_EVENT];
	
		Isgl3dCone * coneMesh = [Isgl3dCone meshWithGeometry:4 topRadius:0 bottomRadius:2 ns:32 nt:32 openEnded:NO];
		_cone = [_container createNodeWithMesh:coneMesh andMaterial:shaderMaterial2];
		_cone.position = Isgl3dVector3Make(7, 0, 0);
	
		Isgl3dCylinder * cylinderMesh = [Isgl3dCylinder meshWithGeometry:4 radius:1 ns:32 nt:32 openEnded:NO];
		_cylinder = [_container createNodeWithMesh:cylinderMesh andMaterial:material];
		_cylinder.position = Isgl3dVector3Make(0, 0, -7);
	
		Isgl3dArrow * arrowMesh = [Isgl3dArrow meshWithGeometry:4 radius:0.4 headHeight:1 headRadius:0.6 ns:32 nt:32];
		_arrow = [_container createNodeWithMesh:arrowMesh andMaterial:material];
		_arrow.position = Isgl3dVector3Make(0, 0, 7);
		
		Isgl3dOvoid * ovoidMesh = [Isgl3dOvoid meshWithGeometry:1.5 b:2 k:0.2 longs:32 lats:32];
		_ovoid = [_container createNodeWithMesh:ovoidMesh andMaterial:material];
		_ovoid.position = Isgl3dVector3Make(0, -4, 0);
		
		Isgl3dGoursatSurface * gouratMesh = [Isgl3dGoursatSurface meshWithGeometry:0 b:0 c:-1 width:2 height:3 depth:2 longs:8 lats:16];
		_gourat = [_container createNodeWithMesh:gouratMesh andMaterial:material];
		_gourat.position = Isgl3dVector3Make(0, 4, 0);
		
		// Add light
		Isgl3dLight * light  = [Isgl3dLight lightWithHexColor:@"FFFFFF" diffuseColor:@"FFFFFF" specularColor:@"FFFFFF" attenuation:0.005];
		[light setDirection:-1 y:-2 z:1];
		light.lightType = DirectionalLight;
		[self.scene addChild:light];
		
		// Schedule updates
		[self schedule:@selector(tick:)];
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
	_containerRotation += 0.2;
	
	_container.rotationY = _containerRotation;
	_torus.rotationY = _containerRotation;
	_cone.rotationY = 2 * _containerRotation;
	_cylinder.rotationY = 3 * _containerRotation;
	_arrow.rotationY = 6 * _containerRotation;
	_gourat.rotationY = 2 * _containerRotation;
	
	// update camera
	[_cameraController update];
}

- (void)objectTouched:(Isgl3dEvent3D *)event {
	Isgl3dClassDebugLog2(Isgl3dLogLevelInfo, @"object touched");
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
	Isgl3dView * view = [ShaderMaterialDemoView view];
	[[Isgl3dDirector sharedInstance] addView:view];
}

@end
