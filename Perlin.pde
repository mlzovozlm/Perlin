int x; //<>// //<>//
int y;
/*
Modify number down below to tweak
 SPACE to generate new map
 ENTER to save as png
 change map size(width, height) in setup()
 
 the higher the globalNoiseScale, 
 --the more fractured the map
 --the lower the UPPER bound for each tile type to compensate for centralized landmass
 --the more fractal shoreline
 */

/*map generated with random new seed everytime currently
 change to noiseSeed(seed) in drawTerrain() to use single seed;
 */
int heightSeed = 48555561;
//perlin noise scale
float globalHeightScale = 0.02; //work best in 0.005-0.03
//increase(> 0) or decrease (< 0) the noise of calculated gradient noise 
float modGradientNoise = -0.01;
//to smooth out map edge
int edgeOutterBound = 20;
int edgeInnerBound = 50;

//color code in rgb
color Mountain = color(69, 69, 69);
color Hill = color(82, 82, 82);
color Forest = color(84, 114, 45);
color Soil = color(126, 175, 70);
color Sand = color(247, 232, 152);
color Shallow = color(85, 174, 240);
color Closed = color(64, 132, 226);
color Deep = color(51, 112, 204);

//upper bound of tile type (0-1)
float FLOOR_CLOSED = 0.02;
float FLOOR_SHALLOW = 0.1;
float FLOOR_SAND = 0.15;
float FLOOR_SOIL = 0.18;
float FLOOR_FOREST = 0.23;
float FLOOR_HILL = 0.4;
float FLOOR_MOUNTAIN = 0.45;
//------------------------------------------------------------------------------------------
void setup() {
  size(576, 576);
  noStroke();
  drawTerrain();
}
//change height value to color
color pickColor(float tileHeightNoise) {
  color picked = Deep;
  if (tileHeightNoise <= FLOOR_CLOSED)
    picked = Deep;
  else if (tileHeightNoise > FLOOR_CLOSED && tileHeightNoise <= FLOOR_SHALLOW)
    picked = Closed;
  else if (tileHeightNoise > FLOOR_SHALLOW && tileHeightNoise <= FLOOR_SAND)
    picked = Shallow;
  else if (tileHeightNoise > FLOOR_SAND && tileHeightNoise <= FLOOR_SOIL)
    picked = Sand;
  else if (tileHeightNoise > FLOOR_SOIL && tileHeightNoise <= FLOOR_FOREST)
    picked = Soil;
  else if (tileHeightNoise > FLOOR_FOREST && tileHeightNoise <= FLOOR_HILL)
    picked = Forest;
  else if (tileHeightNoise > FLOOR_HILL && tileHeightNoise <= FLOOR_MOUNTAIN)
    picked = Hill;
  else if (tileHeightNoise > FLOOR_MOUNTAIN)
    picked = Mountain;
  return picked;
}
//apply mask to prevent cut off at edge
float applyMask(int width, int height, int x, int y, float oldValue) {

  if ( getDistanceToEdge( x, y, width, height ) <= edgeOutterBound) {
    return 0;
  } else if ( getDistanceToEdge( x, y, width, height ) >= edgeInnerBound) {
    return oldValue;
  } else {
    float factor = getFactor( getDistanceToEdge( x, y, width, height ), edgeOutterBound, edgeInnerBound );
    return oldValue * factor;
  }
}
//draw with 1 NoiseSet

void drawTerrain() {
 //noiseSeed(heightSeed);
 noiseSeed(millis());
 int centerX = width / 2;
 int centerY = height / 2;
 for (x = 0; x < width; x++) {
 float distanceX = sq(centerX - x);
 
 for (y= 0; y < height; y++) {
 float distanceY = sq(centerY - y);
 float distanceToCenter = sqrt(distanceX + distanceY);
 //gradient noise from center - the further out, the brighter (stronger)
 float distanceToCenterNoise = distanceToCenter / width + modGradientNoise;
 
 //1 continent mode
 float tileHeightNoise = noise(x * globalHeightScale, y * globalHeightScale) - distanceToCenterNoise;
 if (tileHeightNoise < 0) 
 tileHeightNoise = 0;
 tileHeightNoise = applyMask( width, height, x, y, tileHeightNoise);
 color c = pickColor(tileHeightNoise);
 fill(c);
 rect(x, y, 1, 1);
 }
 }
 }


//draw with 2 NoiseSets
/*
void drawTerrain() {
  float[][] firstNoise = new float[width][height];
  float[][] secondNoise = new float[width][height];
  float[][] combine = new float[width][height];

  firstNoise = generateNoise(firstNoise, globalHeightScale);
  secondNoise = generateNoise(secondNoise, globalHeightScale);
  combine = combineNoiseSet(firstNoise, secondNoise, width, height);

  //draw
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      float tileHeightNoise = combine[x][y];
      color c = pickColor(tileHeightNoise);
      fill(c);
      rect(x, y, 1, 1);
    }
  }
}
*/
//press BACKSPACE to generate new map
//press ENTER to save map
void keyPressed() {
  if (key == ' ') {
    drawTerrain();
  } else if (key == ENTER) {
    saveFrame("map-######.png");
  }
}
void draw() {
}

float[][] generateNoise(float[][] noise, float scale) {
  noiseSeed(millis());
  
  int centerX = width / 2;
  int centerY = height / 2;
  for (x = 0; x < width; x++) {
    float distanceX = sq(centerX - x);

    for (y= 0; y < height; y++) {
      float distanceY = sq(centerY - y);
      float distanceToCenter = sqrt(distanceX + distanceY);
      //gradient noise from center - the further out, the brighter (stronger)
      float distanceToCenterNoise = distanceToCenter / width + modGradientNoise;

      //1 continent mode
      float tileHeightNoise = noise(x * scale, y * scale) - distanceToCenterNoise;
      if (tileHeightNoise < 0) 
        tileHeightNoise = 0;

      noise[x][y] = tileHeightNoise;
    }
  }
  return noise;
}
//combine 2 NoiseSets
float[][] combineNoiseSet(float[][] firstNoise, float[][] secondNoise, int width, int height) {
  float[][] combine = new float[width][height];
  for (int x = 0; x < width; x++) {
    for (int y= 0; y < height; y++) {
      //combine
      float tileHeightNoise = firstNoise[x][y] + secondNoise[x][y];
      //make mask
      tileHeightNoise = applyMask( width, height, x, y, tileHeightNoise);
      if (tileHeightNoise < 0) 
        tileHeightNoise = 0;
      if (tileHeightNoise > 1)
        tileHeightNoise = 1;
      combine[x][y] = tileHeightNoise;
    }
  }
  return combine;
}
float getFactor( int val, int min, int max ) {
  int full = max - min;
  int part = val - min;
  float factor = (float)part / (float)full;
  return factor;
}
int getDistanceToEdge( int x, int y, int width, int height ) {
  int[] distances = new int[]{ y, x, ( width - x ), ( height - y ) };
  int min = distances[ 0 ];
  for (int val : distances) {
    if ( val < min ) {
      min = val;
    }
  }
  return min;
}
