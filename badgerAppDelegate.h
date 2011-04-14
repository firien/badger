//
//  badgerAppDelegate.h
//  badger
//
//  Created by Patrick Griffin on 8/16/10.
//  Copyright 2010 unnamedmundane.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface badgerAppDelegate : NSObject <NSApplicationDelegate> {
  NSStatusItem *statusItem;
  NSString     *selectedColor;
  NSMenu       *statusMenu;
  int    size;
}


@end
