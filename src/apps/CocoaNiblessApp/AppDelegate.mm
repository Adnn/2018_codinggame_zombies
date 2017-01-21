//
//  AppDelegate.mm
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)setupWidgets
{
    NSView *topView = [self.window contentView];
    
    NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 40, 80)];
    [[self.window contentView] addSubview:button];
    
    NSPopUpButton *popupButton = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(5, 80, 200, 200)];
    [popupButton addItemWithTitle:@"Premier choix"];
    [popupButton addItemWithTitle:@"Deuxieme choix"];
    [[self.window contentView] addSubview:popupButton];
    
    NSBox *box = [[NSBox alloc] initWithFrame:NSMakeRect(0, 400, 200, 200)];
    [topView addSubview:box];
    
    NSButton *boxButton = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 60, 20)];
    NSButton *nestedButton = [[NSButton alloc] initWithFrame:NSMakeRect(15, 5, 30, 10)];
    [boxButton addSubview:nestedButton];
    [box addSubview:boxButton];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(100, 100, 800, 600)
                            styleMask: NSTitledWindowMask | NSClosableWindowMask
                            backing: NSBackingStoreBuffered
                            defer: NO];
    
    [self.window setTitle:@"Cocoa Widgets"];
    [self setupWidgets];
    [self.window makeKeyAndOrderFront:NSApp];
}

@end
