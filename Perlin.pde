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
//tile size
int tileSize = 1;

/*map generated with random new seed everytime currently
change to noiseSeed(seed) in drawTerrain() to use single seed;
*/
int seed = 48555561;
//perlin noise scale
float globalNoiseScale = 0.02; //work best in 0.005-0.03
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

//upper bound of tile type (0-255)
int UPPER_DEEP = 30;
int UPPER_CLOSED = 50;
int UPPER_SHALLOW = 70;
int UPPER_SAND = 80;
int UPPER_SOIL = 105;
int UPPER_FOREST = 135;
int UPPER_HILL = 155;
//------------------------------------------------------------------------------------------
void setup() {
  size(576, 576);
  noStroke();
  drawTerrain();
}
//change height value to color
color pickColor(float tileHeight) {
  color picked = Deep;
  if (tileHeight <= UPPER_DEEP)
    picked = Deep;
  else if (tileHeight > UPPER_DEEP && tileHeight <= UPPER_CLOSED)
    picked = Closed;
  else if (tileHeight > UPPER_CLOSED && tileHeight <= UPPER_SHALLOW)
    picked = Shallow;
  else if (tileHeight > UPPER_SHALLOW && tileHeight <= UPPER_SAND)
    picked = Sand;
  else if (tileHeight > UPPER_SAND && tileHeight <= UPPER_SOIL)
    picked = Soil;
  else if (tileHeight > UPPER_SOIL && tileHeight <= UPPER_FOREST)
    picked = Forest;
  else if (tileHeight > UPPER_FOREST && tileHeight <= UPPER_HILL)
    picked = Hill;
  else if (tileHeight > UPPER_HILL)
    picked = Mountain;
  return picked;
}
//apply mask to prevent cut off at edge
float makeMask(int width, int height, int x, int y, float oldValue) {

  if ( getDistanceToEdge( x, y, width, height ) <= edgeOutterBound) {
    return 0;
  } else if ( getDistanceToEdge( x, y, width, height ) >= edgeInnerBound) {
    return oldValue;
  } else {
    float factor = getFactor( getDistanceToEdge( x, y, width, height ), edgeOutterBound, edgeInnerBound );
    return oldValue * factor;
  }
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
void drawTerrain() {
  //noiseSeed(seed);
  noiseSeed(millis());
  int centerX = width / 2;
  int centerY = height / 2;
  for (x = 0; x <= width/tileSize; x++) {
    float distanceX = sq(centerX - x);

    for (y= 0; y <= height/tileSize; y++) {
      float distanceY = sq(centerY - y);
      float distanceToCenter = sqrt(distanceX + distanceY);
      //gradient noise from center - the further out, the brighter (stronger)
      float distanceToCenterNoise = distanceToCenter / width + modGradientNoise;

      //1 continent mode
      float tileHeightNoise = noise(x * globalNoiseScale, y * globalNoiseScale) - distanceToCenterNoise;
      if (tileHeightNoise < 0) 
        tileHeightNoise = 0;
      tileHeightNoise = makeMask( width, height, x, y, tileHeightNoise);
      float tileHeight = tileHeightNoise * 255;
      color c = pickColor(tileHeight);
      fill(c);
      rect(x * tileSize, y * tileSize, tileSize, tileSize);
    }
  }
}
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
