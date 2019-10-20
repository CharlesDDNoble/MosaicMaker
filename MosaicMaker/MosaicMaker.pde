public class MosaicMaker {
  private PImage baseImage;
  private int tileScale;
  private Tile[] tiles;

  public MosaicMaker(PImage baseImage, int tileScale) {
    this.baseImage = baseImage;
    this.tileScale = tileScale;
    this.tiles = null;
  }

  void loadTiles(boolean isUsingColor) {
    File palette = new File(sketchPath()+"/palette");
    ImageProcessor proc = new ImageProcessor();

    if (!palette.exists()) {
      System.out.println("Palette does not exist");
      return;
    }

    File[] fileList = palette.listFiles();
    tiles = new Tile[fileList.length];

    for (int i = 0; i < fileList.length; i++) {
      PImage img = loadImage(fileList[i].getPath());
      img.resize(tileScale, tileScale);
      int col;

      if (!isUsingColor) {
        col = (int) proc.getAverageBrightness(img);
      } else {
        col = proc.getAverageColor(img);
      }

      tiles[i] = new Tile(col, img);
    }
  }

  int findClosestTile(int target) {
    int closestIndex = 0;
    float closestDif = Integer.MAX_VALUE;

    for (int i = 0; i < tiles.length; i++) {
      float rDif = red(target) - red(tiles[i].averageColor);
      float gDif = green(target) - green(tiles[i].averageColor);
      float bDif = blue(target) - blue(tiles[i].averageColor);

      float dif = abs(rDif) + abs(gDif) + abs(bDif);

      if (dif < closestDif) {
        closestIndex = i;
        closestDif = dif;
      }
    }

    return closestIndex;
  }

  void display() {
    if (baseImage == null || tiles == null) 
      throw new NullPointerException();

    baseImage.loadPixels();
    for (int x = 0; x < baseImage.width; x++) {
      for (int y = 0; y < baseImage.height; y++) {
        int loc = x + (y*baseImage.width);
        int ind = findClosestTile(baseImage.pixels[loc]);
        if (alpha(baseImage.pixels[loc]) > 0) {
          image(tiles[ind].img, x*tileScale, y*tileScale);
        }
      }
    }
  }

  void drawToGraphic(PGraphics graphic) {
    if (baseImage == null || tiles == null) 
      throw new NullPointerException();

    baseImage.loadPixels();
    for (int x = 0; x < baseImage.width; x++) {
      for (int y = 0; y < baseImage.height; y++) {
        int loc = x + (y*baseImage.width);
        int ind = findClosestTile(baseImage.pixels[loc]);
        if (alpha(baseImage.pixels[loc]) > 0) {
          graphic.image(tiles[ind].img, x*tileScale, y*tileScale);
        }
      }
    }
  }
}
