//TO DO:
//PALETTE OPTIONS 
//  - use only r,g, or b 
//  - saving palettes instead of erasing and recreating
//  - looping - creating and saving multiple images at a time

String image1 = ".\\batman-thumb.jpg";
String image2 = ".\\pepe2.jpg";
int mosTileScale = 16;
int mosScale = 1;
int threshold = 50;
boolean render = false;
boolean makePalette = true;

PImage baseImg;
PImage tileImg;
PGraphics mos;
MosaicMaker mosMaker;
ImageProcessor proc;


void setup() {
  baseImg = loadImage(image1);
  tileImg = loadImage(image2);
  baseImg.resize(baseImg.width*mosScale/mosTileScale, 
                 baseImg.height*mosScale/mosTileScale);

  //make/remake the palette
  if (makePalette) {
    proc = new ImageProcessor();
    int avgCol = (int) proc.getAverageColor(tileImg);
    proc.createPalette(tileImg, avgCol, threshold);
  }

  //if render then display in processing widow, else just print to file
  if (render) {
    surface.setResizable(true);
    surface.setSize(baseImg.width*mosTileScale, 
                    baseImg.height*mosTileScale);
  } else {
    mos = createGraphics(baseImg.width*mosTileScale, 
                         baseImg.height*mosTileScale);
  }

  //create the mosaic maker and load in the Tiles into its Tile[]
  mosMaker = new MosaicMaker(baseImg, mosTileScale);
  mosMaker.loadTiles(true);
}

void draw() {
  //if render then display in processing widow, else just print to file
  if (render) {
    mosMaker.display();
    save("mosaic.png");
    println("Done!");
    noLoop();
  } else {
    mos.beginDraw();
    mosMaker.drawToGraphic(mos);
    mos.endDraw();
    mos.save("mosaic.png");
    println("Done!");
    exit();
  }
}
