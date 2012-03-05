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

#import "Isgl3dFollowNode.h"
#import "Isgl3dGLU.h"

@implementation Isgl3dFollowNode

@synthesize keepHorizontal = _keepHorizontal;

+ (id)nodeWithTarget:(Isgl3dNode *)target {
	return [[[self alloc] initWithTarget:target] autorelease];
}

- (id)initWithTarget:(Isgl3dNode *)target {
    if ((self = [super init])) {
    	_target = [target retain];
		_isFirstUpdate = YES;
    }
	
    return self;
}

- (void)dealloc {
	[_target release];
	
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
	Isgl3dFollowNode * copy = [super copyWithZone:zone];
	
	copy->_target = [_target retain];
	copy->_oldTargetPosition = _oldTargetPosition;
	copy->_targetMovementIT = _targetMovementIT;
	copy->_isFirstUpdate = _isFirstUpdate;
	copy->_keepHorizontal = _keepHorizontal;
	
	return copy;
}


- (void)updateWorldTransformation:(Isgl3dMatrix4 *)targetTransformation {
	// Get current position
	Isgl3dVector3 currentTargetPosition = [_target worldPosition];

	// Initialise old target position if necessary
	if (_isFirstUpdate) {
		_isFirstUpdate = NO;
        _oldTargetPosition = currentTargetPosition;
	}

	if (iv3DistanceBetween(&currentTargetPosition, &_oldTargetPosition) > 0.01) {
		// Calculate transformation matrix along line of movement of target
		Isgl3dMatrix4 targetMovementTransformation;
		if (_keepHorizontal) {
            targetMovementTransformation = Isgl3dMatrix4MakeLookAt(currentTargetPosition.x, currentTargetPosition.y, currentTargetPosition.z,
                                                                   (2.0f * currentTargetPosition.x) - _oldTargetPosition.x, currentTargetPosition.y, (2.0f * currentTargetPosition.z) - _oldTargetPosition.z,
                                                                   0.0f, 1.0f, 0.0f);
		} else {
            targetMovementTransformation = Isgl3dMatrix4MakeLookAt(currentTargetPosition.x, currentTargetPosition.y, currentTargetPosition.z,
                                                                   (2.0f * currentTargetPosition.x) - _oldTargetPosition.x, (2.0f * currentTargetPosition.y) - _oldTargetPosition.y, (2.0f * currentTargetPosition.z) - _oldTargetPosition.z,
                                                                   0.0f, 1.0f, 0.0f);
		}
		
        _targetMovementIT = Isgl3dMatrix4Invert(targetMovementTransformation, NULL);

		[self setTransformation:_targetMovementIT];

	}

    _oldTargetPosition = currentTargetPosition;

	[super updateWorldTransformation:targetTransformation];
}


@end
