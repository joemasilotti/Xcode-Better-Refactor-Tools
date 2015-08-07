#import "XMASRefactorMethodAction.h"
#import "XMASAlert.h"
#import "XcodeInterfaces.h"
#import "XMASObjcMethodDeclaration.h"
#import "XMASObjcMethodDeclarationParser.h"
#import "XMASChangeMethodSignatureController.h"
#import "XMASChangeMethodSignatureControllerProvider.h"
#import "XMASXcode.h"
#import "XMASTokenizer.h"

NSString * const noMethodSelected = @"No method selected. Put your cursor inside of a method declaration";

@interface XMASRefactorMethodAction () <XMASChangeMethodSignatureControllerDelegate>
@property (nonatomic) id currentEditor;
@property (nonatomic) XMASAlert *alerter;
@property (nonatomic) XMASTokenizer *tokenizer;
@property (nonatomic) XMASChangeMethodSignatureControllerProvider *controllerProvider;
@property (nonatomic) XMASObjcMethodDeclarationParser *methodDeclParser;

@property (nonatomic) XMASChangeMethodSignatureController *controller;

@end

@implementation XMASRefactorMethodAction

- (instancetype)initWithAlerter:(XMASAlert *)alerter
                      tokenizer:(XMASTokenizer *)tokenizer
             controllerProvider:(XMASChangeMethodSignatureControllerProvider *)controllerProvider
               methodDeclParser:(XMASObjcMethodDeclarationParser *)methodDeclParser {
    if (self = [super init]) {
        self.alerter = alerter;
        self.tokenizer = tokenizer;
        self.methodDeclParser = methodDeclParser;
        self.controllerProvider = controllerProvider;
    }

    return self;
}

- (void)setupWithEditor:(id)editor {
    self.currentEditor = editor;
}

- (void)safelyRefactorMethodUnderCursor {
    @try {
        [self refactorMethodUnderCursor];
    }
    @catch (NSException *exception) {
        [self.alerter flashComfortingMessageForException:exception];
    }
}

- (void)refactorMethodUnderCursor {
    NSUInteger cursorLocation = [self cursorLocation];
    NSString *currentFilePath = [self currentSourceCodeFilePath];

    NSArray *tokens = [self.tokenizer tokensForFilePath:currentFilePath];
    NSArray *selectors = [self.methodDeclParser parseMethodDeclarationsFromTokens:tokens];

    XMASObjcMethodDeclaration *selectedMethod;
    for (XMASObjcMethodDeclaration *selector in selectors) {
        if (cursorLocation > selector.range.location && cursorLocation < selector.range.location + selector.range.length) {
            selectedMethod = selector;
            break;
        }
    }

    if (!selectedMethod) {
        [self.alerter flashMessage:noMethodSelected];
        return;
    }

    self.controller = [self.controllerProvider provideInstanceWithDelegate:self];
    [self.controller refactorMethod:selectedMethod inFile:currentFilePath];
}

#pragma mark - <XMASChangeMethodSignatureControllerDelegate>

- (void)controllerWillDisappear:(XMASChangeMethodSignatureController *)controller {
    self.controller = nil;
}

#pragma mark - editor helpers

- (NSString *)currentSourceCodeFilePath {
    if ([self.currentEditor respondsToSelector:@selector(sourceCodeDocument)]) {
        return [[[self.currentEditor sourceCodeDocument] fileURL] path];
    }
    return nil;
}

- (NSUInteger)cursorLocation {
    id currentLocation = [[self.currentEditor currentSelectedDocumentLocations] lastObject];
    if ([currentLocation respondsToSelector:@selector(characterRange)]) {
        return [currentLocation characterRange].location;
    }

    return UINT_MAX;
}

#pragma mark - NSObject

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
