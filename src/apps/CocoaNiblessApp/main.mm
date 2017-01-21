#import "AppDelegate.h"

#import <Cocoa/Cocoa.h>

int main(int argc, const char** argv)
{
    NSApplication *app = [NSApplication sharedApplication];
    [app setDelegate:[[AppDelegate alloc] init]];
    [app run];
    return 0;
}