//
//  badgerAppDelegate.m
//  badger
//
//  Created by Patrick Griffin on 8/16/10.
//  Copyright 2010 unnamedmundane.com. All rights reserved.
//

#import "badgerAppDelegate.h"

@interface badgerAppDelegate (Private)
- (NSArray *)colorArray;
- (NSString *)promptForCharacter;
- (void)generateBadge:(NSString *)title;
@end

@implementation badgerAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  statusMenu = [[NSMenu alloc] initWithTitle:@"Badger"];
  statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
  [statusItem setMenu:statusMenu];
  [statusItem setImage:[NSImage imageNamed:@"badge"]];
  [statusItem setAlternateImage:[NSImage imageNamed:@"badge_alt"]];
  [statusItem setHighlightMode:YES];

  NSMenuItem *newItem;

  newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Number" action:NULL keyEquivalent:@""];
  [newItem setEnabled:NO];
  [statusMenu addItem:newItem];
  [newItem release];

  int counter = 1;
  while (counter < 11) {
    NSString *title = [NSString stringWithFormat:@"%d", counter];
    newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:title action:NULL keyEquivalent:@""];
    [newItem setTarget:self];
    [newItem setAction:@selector(getItemTitle:)];
    [statusMenu addItem:newItem];
    [newItem release];
    counter++;
  }

  //custom char
  newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Custom…" action:NULL keyEquivalent:@""];
  [newItem setTarget:self];
  [newItem setAction:@selector(customCharacter)];
  [statusMenu addItem:newItem];
  [newItem release];

  NSMenuItem *separatorItem = [NSMenuItem separatorItem];
  [statusMenu addItem:separatorItem];

  //colors
  newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Color" action:NULL keyEquivalent:@""];
  [newItem setEnabled:NO];
  [statusMenu addItem:newItem];
  [newItem release];

  selectedColor = @"Red";
  [statusMenu setAutoenablesItems:NO];
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

  newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Size" action:NULL keyEquivalent:@""];
  [newItem setEnabled:NO];
  [statusMenu addItem:newItem];
  [newItem release];

  size = 32;//default to 32
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

  separatorItem = [NSMenuItem separatorItem];
  [statusMenu addItem:separatorItem];

  //quit
  newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Quit" action:NULL keyEquivalent:@""];
  [newItem setTarget:self];
  [newItem setAction:@selector(quitApp:)];
  [statusMenu addItem:newItem];
  [newItem release];

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  [statusMenu release];
  [statusItem release];
}

- (void)quitApp:(id)sender {
  [NSApp terminate:sender];
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

- (void)getItemTitle:(id)sender {
  [self generateBadge:[sender title]];
}

- (void)generateBadge:(NSString *)title {
  int pixelsWide = size;
  int pixelsHigh = size;

  const char *step = [title cStringUsingEncoding:NSUTF8StringEncoding];

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

    // create the CGGradient
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, gradientLocations, 4);

    int lineWidth = floor(pixelsHigh / 10);
    if ((lineWidth % 2) != 0) {
      lineWidth++;//ensure this is an even number
    }
    int padding = floor(pixelsHigh / 11);
    int inset = floor(lineWidth / 2) + padding;
    int diameter = pixelsWide - lineWidth - (padding * 2);
    CGRect circle = CGRectMake(inset, inset, diameter, diameter);

    // draw border with shadow
    CGFloat shadowColorValues[4] = {0.4, 0.4, 0.4, 0.9};
    CGColorRef shadowColor = CGColorCreate(colorSpace, shadowColorValues);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0, 0.0), floor(pixelsHigh / 9), shadowColor);
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextAddEllipseInRect(context, circle);
    CGContextStrokePath(context);
    CGColorRelease(shadowColor);

    // fill with selected color
    CGContextBeginPath(context);
    CGContextAddEllipseInRect(context, circle);
    CGContextClip(context);
    NSArray *colorArray = [self colorArray];
    CGContextSetRGBFillColor(context, [[colorArray objectAtIndex:0] floatValue], [[colorArray objectAtIndex:1] floatValue], [[colorArray objectAtIndex:2] floatValue], 1.0);
    CGContextFillRect(context, CGRectMake(0,0, pixelsWide, pixelsHigh));
    // draw the gradient
    CGPoint center = CGPointMake(pixelsWide / 2, 0);
    CGContextDrawRadialGradient(context, gradient, center, 0, center, pixelsHigh, kCGGradientDrawsAfterEndLocation);
    // clean up the gradient
    CGGradientRelease(gradient);

    // draw text
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    CGContextSetShadow(context, CGSizeMake(0.0, -3.0), 2.0);
    CGContextSelectFont(context, "Helvetica-Bold", floor(pixelsHigh / 1.5), kCGEncodingMacRoman);
    //determine length of text first
    CGPoint startText = CGContextGetTextPosition(context);
    CGContextSetTextDrawingMode(context, kCGTextInvisible);
    CGContextShowText(context, step, strlen(step));
    CGPoint endText = CGContextGetTextPosition(context);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextShowTextAtPoint(context, (pixelsWide / 2.f) - ((endText.x - startText.x) / 2.f), floor(pixelsHigh / 3.5), step, strlen(step));

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

#pragma mark Alert
- (void)customCharacter {
  NSString *customChar = [self promptForCharacter];
  if (customChar != nil)
    [self generateBadge:customChar];
}

- (NSString *)promptForCharacter {
  NSAlert *alert = [NSAlert alertWithMessageText:@"Enter a Character" defaultButton:@"OK"
      alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@""];

  NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
  [alert setAccessoryView:input];
  //[input becomeFirstResponder];
  [alert.window makeFirstResponder:input];
  [[input currentEditor] setSelectedRange:NSMakeRange(0,0)];
  NSInteger button = [alert runModal];
  NSString *inputString;
  if (button == NSAlertDefaultReturn) {
    [input validateEditing];
    inputString = [[input stringValue] copy];
  } else if (button == NSAlertAlternateReturn) {
    inputString = nil;
  } else {
    NSAssert1(NO, @"Invalid input dialog button %d", button);
    inputString = nil;
  }
  [input release];
  return [inputString autorelease];
}

@end
