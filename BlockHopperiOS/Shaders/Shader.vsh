//
//  Shader.vsh
//  BlockHopperiOS
//
//  Created by David Samuelsen on 11-09-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

attribute vec4 position;
attribute vec4 color;

varying vec4 colorVarying;

uniform float translate;

void main()
{
    gl_Position = position;
    gl_Position.y += sin(translate) / 2.0;

    colorVarying = color;
}
