//
//  main.m
//  badger
//
//  Created by Patrick Griffin on 8/16/10.
//  Copyright 2010 unnamedmundane.com All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "badgerAppDelegate.h"

int main(int argc, char *argv[]) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSApplication *application = [NSApplication sharedApplication];

  badgerAppDelegate *appDelegate = [[[badgerAppDelegate alloc] init] autorelease];

  [application setDelegate:appDelegate];
  [application run];

  [pool drain];

  return EXIT_SUCCESS;
}
