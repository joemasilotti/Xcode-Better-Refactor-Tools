#import "XMASEditMenu.h"
#import "XMASXcode.h"
#import "XMASRefactorMethodAction.h"
#import "XMASAlert.h"
#import "XMASObjcMethodDeclarationParser.h"
#import "XMASChangeMethodSignatureControllerProvider.h"
#import "XMASWindowProvider.h"

@implementation XMASEditMenu

- (void)attach {
    NSMenu *editMenu = [XMASXcode menuWithTitle:@"Edit"];
    [editMenu addItem:NSMenuItem.separatorItem];
    [editMenu addItem:self.refactorCurrentMethodItem];
}

#pragma mark - Menu items

- (NSMenuItem *)refactorCurrentMethodItem {
    NSMenuItem *item = [[NSMenuItem alloc] init];
    item.title = @"Refactor Current Method";
    item.target = self;
    item.action = @selector(refactorCurrentMethodAction:);

    unichar f6Char = NSF6FunctionKey;
    item.keyEquivalent = [NSString stringWithCharacters:&f6Char length:1];
    item.keyEquivalentModifierMask = NSCommandKeyMask;
    return item;
}

#pragma mark - Menu Actions

- (void)refactorCurrentMethodAction:(id)sender {
    id editor = [XMASXcode currentEditor];
    XMASAlert *alerter = [[XMASAlert alloc] init];
    XMASObjcMethodDeclarationParser *methodDeclParser = [[XMASObjcMethodDeclarationParser alloc] init];
    XMASWindowProvider *windowProvider = [[XMASWindowProvider alloc] init];
    XMASChangeMethodSignatureControllerProvider *controllerProvider = [[XMASChangeMethodSignatureControllerProvider alloc] initWithWindowProvider:windowProvider];
    XMASRefactorMethodAction *refactorAction = [[XMASRefactorMethodAction alloc] initWithEditor:editor
                                                                                        alerter:alerter
                                                                             controllerProvider:controllerProvider
                                                                               methodDeclParser:methodDeclParser];
    [refactorAction refactorMethodUnderCursor];
}

@end
