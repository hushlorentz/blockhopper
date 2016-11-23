//
//  Shader.fsh
//  BlockHopperiOS
//
//  Created by David Samuelsen on 11-09-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
