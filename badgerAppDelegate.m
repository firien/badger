//
//  badgerAppDelegate.m
//  badger
//
//  Created by Patrick Griffin on 8/16/10.
//  Copyright 2010 unnamedmundane. All rights reserved.
//

#import "badgerAppDelegate.h"

@interface badgerAppDelegate (Private)
- (NSArray *)colorArray;
@end

@implementation badgerAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
   statusMenu = [[NSMenu alloc] initWithTitle:@"Badger"];
  statusMenu.delegate = self;
  statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
  [statusItem setMenu:statusMenu];
  [statusItem setImage:[NSImage imageNamed:@"badge"]];
  [statusItem setHighlightMode:YES];

  NSMenuItem *newItem;
  int counter = 1;
  while (counter < 11) {
    NSString *title = [NSString stringWithFormat:@"%d", counter];
    newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:title action:NULL keyEquivalent:@""];
    [newItem setTarget:self];
    [newItem setAction:@selector(generateBadge:)];
    [statusMenu addItem:newItem];
    [newItem release];
    counter++;
  }

  NSMenuItem *separatorItem = [NSMenuItem separatorItem];
  [statusMenu addItem:separatorItem];

  //colors
  selectedColor = @"Red";
  NSArray *colors = [[NSArray alloc] initWithObjects:@"Red", @"Blue", @"Green", @"Black", nil];
  for (NSString *title in colors) {
    newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:title action:NULL keyEquivalent:@""];
    if ([title isEqualToString:selectedColor]) {
      [newItem setState:NSOnState];
    }
    [newItem setTarget:self];
    [newItem setAction:@selector(setColor:)];
    [statusMenu addItem:newItem];
    [newItem release];
  }
  [colors release];

  separatorItem = [NSMenuItem separatorItem];
  [statusMenu addItem:separatorItem];

  //sizes
  size = 32;
  int sizes = 16;
  while (sizes < 130) {
    NSString *title = [NSString stringWithFormat:@"%d", sizes];
    newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:title action:NULL keyEquivalent:@""];
    if (sizes == 32) {
      [newItem setState:NSOnState];
    }
    [newItem setTarget:self];
    [newItem setAction:@selector(setSize:)];
    [statusMenu addItem:newItem];
    [newItem release];
    sizes = sizes * 2;
  }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  [statusMenu release];
  [statusItem release];
}

- (void)setSize:(id)sender {
  //find selected color and turn off
  NSMenuItem *oldSize = [statusMenu itemWithTitle:[NSString stringWithFormat:@"%d", size]];
  [oldSize setState:NSOffState];
  [sender setState:NSOnState];
  size = [[sender title] intValue];
}

- (void)setColor:(id)sender {
  //find selected color and turn off
  NSMenuItem *oldColor = [statusMenu itemWithTitle:selectedColor];
  [oldColor setState:NSOffState];
  [sender setState:NSOnState];
  selectedColor = [sender title];
}

- (void)generateBadge:(id)sender {
  // insert code here...
  int pixelsWide = size;
  int pixelsHigh = size;

  const char *step = [[sender title] cStringUsingEncoding:NSUTF8StringEncoding];
  
  int bitmapBytesPerRow = (pixelsWide * 4);
  
  CGImageRef theCGImage = NULL;
  CGContextRef context = NULL;
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  
  // create the bitmap context
  context = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh, 8, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
  
  if (context != NULL) {
    CGFloat gradientLocations[4] = { 0.0, 0.4, 0.6, 1.0 };
    CGFloat colors[16] = {
      0.0, 0.0, 0.0, 0.6,
      0.0, 0.0, 0.0, 0.4,
      0.0, 0.0, 0.0, 0.1,
      0.0, 0.0, 0.0, 0.0
    };
    
    // create the CGGradient and then release the gray color space
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, gradientLocations, 4);
    
    int lineWidth = floor(pixelsHigh / 10);//this should be an even number
    if ((lineWidth % 2) != 0) {
      lineWidth++;
    }
    int padding = floor(pixelsHigh / 11);
    int inset = floor(lineWidth / 2) + padding;
    int diameter = pixelsWide - lineWidth - (padding * 2);
    CGRect circle = CGRectMake(inset, inset, diameter, diameter);
    // create the start and end points for the gradient vector (straight down)
    CGContextSaveGState(context);
    //shadow
    CGFloat shadowColorValues[4] = {0, 0, 0, 0.9};
    CGColorRef shadowColor = CGColorCreate(colorSpace, shadowColorValues);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0, 0.0), floor(pixelsHigh / 9), shadowColor);
    CGContextSetLineWidth(context, lineWidth);
    CGContextAddEllipseInRect(context, circle);
    CGContextStrokePath(context);
    CGColorRelease(shadowColor);
    
    // draw the gradient into the gray bitmap context
    CGContextBeginPath(context);
    CGContextAddEllipseInRect(context, circle);
    CGContextClip(context);
    //fill with seleceted color
    NSArray *colorArray = [self colorArray];
    CGContextSetRGBFillColor(context, [[colorArray objectAtIndex:0] floatValue], [[colorArray objectAtIndex:1] floatValue], [[colorArray objectAtIndex:2] floatValue], 1.0);
    CGContextFillRect(context, CGRectMake(0,0, pixelsWide, pixelsHigh));
    CGPoint center = CGPointMake(pixelsWide / 2, 0);
    CGContextDrawRadialGradient(context, gradient, center, 0, center, pixelsHigh, kCGGradientDrawsAfterEndLocation);
    CGContextRestoreGState(context);
    
    CGContextSetLineWidth(context, pixelsHigh / 10);
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextAddEllipseInRect(context, circle);
    CGContextStrokePath(context);
    
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    CGContextSetShadow(context, CGSizeMake(0.0, -3.0), 2.0);
    CGContextSelectFont(context, "Helvetica-Bold", floor(pixelsHigh / 1.5), kCGEncodingMacRoman);
    // Next we set the text matrix to flip our text upside down. We do this because the context itself
    // is flipped upside down relative to the expected orientation for drawing text (much like the case for drawing Images & PDF).
    CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, 1.0));
    
    //determine length of text first
    CGPoint startText = CGContextGetTextPosition(context);
    CGContextSetTextDrawingMode(context, kCGTextInvisible);
    CGContextShowText(context, step, strlen(step));
    CGPoint endText = CGContextGetTextPosition(context);
    
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextShowTextAtPoint(context, (pixelsWide / 2) - ((endText.x - startText.x) / 2), floor(pixelsHigh / 3.5), step, strlen(step));
    
    // clean up the gradient
    CGGradientRelease(gradient);
    
    // convert the context into a CGImageRef and release the context
    theCGImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    OSStatus err = noErr;
    PasteboardRef theClipboard;
    
    err = PasteboardCreate(kPasteboardClipboard, &theClipboard);
    err = PasteboardClear(theClipboard);
    
    CFMutableDataRef url = CFDataCreateMutable(kCFAllocatorDefault, 0);
    
    CFStringRef type = kUTTypePNG;
    size_t count = 1;
    CFDictionaryRef options = NULL;
    CGImageDestinationRef dest = CGImageDestinationCreateWithData(url, type, count, options);
    CGImageDestinationAddImage(dest, theCGImage, NULL);
    CGImageDestinationFinalize(dest);
    
    err = PasteboardPutItemFlavor(theClipboard, (PasteboardItemID)1, type, url, 0);
    CFRelease(url);
    CFRelease(dest);
    CFRelease(theCGImage);
    CFRelease(theClipboard);
  }
  // clean up the colorspace
  CGColorSpaceRelease(colorSpace);
}

- (NSArray *)colorArray {
  NSString *path = [[NSBundle mainBundle] pathForResource:@"colors" ofType:@"plist"];
  NSDictionary *colors = [NSDictionary dictionaryWithContentsOfFile:path];
  return [colors valueForKey:selectedColor];
}

#pragma mark NSMenuDelegate
- (void)menu:(NSMenu *)menu willHighlightItem:(NSMenuItem *)item {

}
@end
