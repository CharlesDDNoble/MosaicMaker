public class ImageProcessor {

  ImageProcessor() {}

  //function replace: copy img and replace oldColor pixels with newColor.
  //maxDif is the maximum difference the oldColor can be with the pixels
  //it can replace. Returns the copy.
  PImage replace(PImage img, int oldColor, int newColor, int maxDif) {
    PImage copy = img.copy();
    copy.loadPixels();
    for (int i = 0; i < img.pixels.length; i++) {
      float a = alpha(img.pixels[i]);
      float rdif = (float)(red(oldColor)) - red(img.pixels[i]);
      float gdif = (float)(green(oldColor)) - green(img.pixels[i]);
      float bdif = (float)(blue(oldColor)) - blue(img.pixels[i]);

      //if (a == 0) a += 1;

      if (abs(rdif) <= maxDif && abs(gdif) <= maxDif && abs(bdif) <= maxDif) {
        copy.pixels[i] = color(red(newColor) + rdif, 
          green(newColor) + gdif, 
          blue(newColor) + bdif, 
          a);
      }
    }

    copy.updatePixels();
    return copy;
  }

  //function maskRGB: copy img and mask off the red, blue, and/or green 
  //element of every pixel. type determines which elements to mask off
  //where: 0b100 is red, 0b010 is green, and 0b001 is blue. 
  //Returns the copy.
  PImage maskRGB(PImage img, int type) {
    if (type < 1 || type > 7) {
      throw new NumberFormatException();
    }
    PImage copy = img.copy();
    copy.loadPixels();

    for (int i = 0; i < img.pixels.length; i++) {
      if ((type & 4) == 4) { //mask off red
        copy.pixels[i] &= 0xFF00FFFF;
      }
      if ((type & 2) == 2) { //mask off green
        copy.pixels[i] &= 0xFFFF00FF;
      }
      if ((type & 1) == 1) { //mask off blue
        copy.pixels[i] &= 0xFFFFFF00;
      }
    }

    copy.updatePixels();

    return copy;
  }

  //function swap: copies img and swaps the red, green, and blue elements 
  //of every pixel in the image. Color elements are indexed as such:
  //red = 2, green = 1, blue = 0.
  //rSwap is the element to replace the red values of the img with.
  //gSwap is the element to replace the green values of the img with.
  //bSwap is the element to replace the blue values of the img with.
  //e.g. swap(img, 2, 0, 1) - red stays the same, green and blue are swapped
  //e.g. swap(img, 0, 0, 1) - green and red are swapped with blue, blue is green
  //Returns the copy.
  PImage swap(PImage img, int rSwap, int gSwap, int bSwap) {
    //TO DO: VALIDATE swap
    PImage copy = img.copy();
    copy.loadPixels();
    int[] rgb = new int[3];

    for (int i = 0; i < img.pixels.length; i++) {
      rgb[2] = (int) red(copy.pixels[i]);
      rgb[1] = (int) green(copy.pixels[i]);
      rgb[0] = (int) blue(copy.pixels[i]);

      //clear rgb
      copy.pixels[i] &= 0xFF000000;
      copy.pixels[i] |= rgb[rSwap] << 16; //red
      copy.pixels[i] |= rgb[gSwap] << 8; //green
      copy.pixels[i] |= rgb[bSwap]; //blue
    }

    copy.updatePixels();

    return copy;
  }

  //function invert: copies the img and inverts the rgb values
  //for each pixel in the img. Returns the copy.
  PImage invert(PImage img) {
    PImage copy = img.copy();
    copy.loadPixels();

    for (int i = 0; i < copy.pixels.length; i++) {
      int r = (int) red(copy.pixels[i]);
      int g = (int) green(copy.pixels[i]);
      int b = (int) blue(copy.pixels[i]);
      copy.pixels[i] = color(255-r, 255-g, 255-b);
    }

    copy.updatePixels();
    return copy;
  }

  PImage grayscale(PImage img) {
    PImage copy = img.copy();
    copy.loadPixels();

    for (int i = 0; i < copy.pixels.length; i++) {
      int col = copy.pixels[i];
      float bright = brightness(col);
      copy.pixels[i] = color(bright,bright,bright);
    }

    copy.updatePixels();
    return copy;
  }

  //function invert: copies the img and increases/decreases
  //the brightness of each pixel in the img by value. Returns the copy.
  PImage contrast(PImage img, int value) {
    //TO DO: validate value 0-765? or 255?
    PImage copy = img.copy();
    copy.loadPixels();

    for (int i = 0; i < copy.pixels.length; i++) {
      int col = copy.pixels[i];
      float bright = brightness(col);
      float dif = (bright - value)/3;
      copy.pixels[i] = color(red(col)+dif, 
        green(col)+dif, 
        blue(col)+dif);
    }

    copy.updatePixels();
    return copy;
  }

  private void checkForPalette() {
    File palette = new File(sketchPath()+"/palette");
    
    //if it is not a dir
    if (!palette.isDirectory()) { 
      println("palette exists but is not a directory");
      //if the dir can not be made
      if (!palette.mkdir()) { 
        println("Could not create palette directory");
        System.exit(-1);
      }
    } else { //if the file is a dir
      println("palette already exists - attempting to overwrite");
      File[] junkFiles = palette.listFiles();
      //clean the dir
      for (int i = 0; i < junkFiles.length; i++) {
        if (!junkFiles[i].delete()) {
          println("Could not delete: "+junkFiles[i].toPath());
        }
      }
    }
  }


  //function createPalette: creates "palette" folder containing
  //colorized versions of img by replacing any pixel within maxDif
  //of oldColor with a new color, these images are written into the
  //folder.
  void createPalette(PImage img, int oldColor, int maxDif) {
    //validate rgb
    checkForPalette();
    
    PImage copy = img.copy();
    copy.resize(512, 0);

    //generate colorized images and save them
    for (int r = 0; r < 255; r+=50) {
      for (int g = 0; g < 255; g+=50) {
        for (int b = 0; b < 255; b+=50) {
          int newColor = color(r, g, b);
          PImage colored = replace(copy, oldColor, newColor, maxDif);
          colored.save("./palette/("+r+","+g+","+b+")"+".png");
        }
      }
    }
  }

  //function createPalette: creates "palette" folder containing
  //grayscale versions of img of varying intesities, these images
  //are written into the folder.
  void createPalette(PImage img) {
    checkForPalette();
    PImage copy = img.copy();
    copy.resize(512, 0);

    //generate images with varying brightness and save them
    for (int bright = 0; bright < 255; bright+=2) {
      PImage colored = contrast(copy, bright);
      colored.save("./palette/("+bright+")"+".png");
    }
  }

  //function getAverageColor: computes the average color of the img
  //by summing the pixel values and divding by the number of pixels.
  //Returns the average color in the format of the color datatype.
  int getAverageColor(PImage img) {
    img.loadPixels();
    long[] colorSum = {0, 0, 0};
    long numOfPixs = 0;

    //for each pixel
    for (int i = 0; i < img.pixels.length; i++) {
      float alpha = alpha(img.pixels[i]);

      //if the alpha value is greater than 0, sum its rgb values
      if (alpha > 0) {
        colorSum[0] += red(img.pixels[i]);
        colorSum[1] += green(img.pixels[i]);
        colorSum[2] += blue(img.pixels[i]);
        numOfPixs++;
      }
    }

    return color((float) colorSum[0]/numOfPixs, 
      (float) colorSum[1]/numOfPixs, 
      (float) colorSum[2]/numOfPixs);
  }

  //function getAverageColor: computes the average brightness of the img
  //by summing the pixel values and divding by the number of pixels.
  //Returns the average brightness.
  float getAverageBrightness(PImage img) {
    img.loadPixels();
    long brightness = 0;
    long numOfPixs = 0;

    //for each pixel
    for (int i = 0; i < img.pixels.length; i++) {
      float alpha = alpha(img.pixels[i]);

      //if the alpha value is greater than 0, sum its brightness
      if (alpha > 0) {
        brightness += brightness(img.pixels[i]);
        numOfPixs++;
      }
    }

    return (float) brightness/numOfPixs;
  }
}
