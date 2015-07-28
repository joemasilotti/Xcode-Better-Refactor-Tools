#import "XMASEditMenu.h"
#import "XMASXcode.h"
#import "XMASRefactorMethodAction.h"
#import "XMASAlert.h"
#import "XMASObjcMethodDeclarationParser.h"
#import "XMASChangeMethodSignatureControllerProvider.h"
#import "XMASWindowProvider.h"
#import "XMASRefactorMethodActionProvider.h"
#import "XMASIndexedSymbolRepository.h"
#import "XMASObjcCallExpressionRewriter.h"
#import "XMASObjcMethodCallParser.h"
#import "XMASObjcCallExpressionTokenFilter.h"
#import "XMASObjcCallExpressionStringWriter.h"

@interface XMASEditMenu ()
@property (nonatomic) XMASRefactorMethodActionProvider *actionProvider;
@end

@implementation XMASEditMenu

- (instancetype)initWithRefactorMethodActionProvider:(XMASRefactorMethodActionProvider *)actionProvider {
    if (self = [super init]) {
        self.actionProvider = actionProvider;
    }

    return self;
}

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

    XMASIndexedSymbolRepository *indexedSymbolRepository = [[XMASIndexedSymbolRepository alloc] initWithWorkspaceWindowController:[XMASXcode currentWorkspaceController]];

    XMASObjcCallExpressionTokenFilter *callExpressionTokenFilter = [[XMASObjcCallExpressionTokenFilter alloc] init];
    XMASObjcCallExpressionStringWriter *callExpressionStringWriter = [[XMASObjcCallExpressionStringWriter alloc] init];
    XMASObjcMethodCallParser *methodCallParser = [[XMASObjcMethodCallParser alloc] initWithCallExpressionTokenFilter:callExpressionTokenFilter];

    XMASObjcCallExpressionRewriter *callExpressionRewriter = [[XMASObjcCallExpressionRewriter alloc] initWithAlerter:alerter
                                                                                                callExpressionParser:methodCallParser
                                                                                          callExpressionStringWriter:callExpressionStringWriter];

    XMASChangeMethodSignatureControllerProvider *controllerProvider = [[XMASChangeMethodSignatureControllerProvider alloc] initWithWindowProvider:windowProvider
                                                                                                                                          alerter:alerter
                                                                                                                          indexedSymbolRepository:indexedSymbolRepository
                                                                                                                           callExpressionRewriter:callExpressionRewriter
                                                                                                                       callExpressionStringWriter:callExpressionStringWriter];

    XMASRefactorMethodAction *refactorAction = [self.actionProvider provideInstanceWithEditor:editor
                                                                                      alerter:alerter
                                                                           controllerProvider:controllerProvider
                                                                             methodDeclParser:methodDeclParser];

    [refactorAction safelyRefactorMethodUnderCursor];
}


@end
