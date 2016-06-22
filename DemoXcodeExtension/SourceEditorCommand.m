//
//  SourceEditorCommand.m
//  DemoXcodeExtension
//
//  Created by Ricky on 16/6/22.
//  Copyright © 2016年 yourcompany. All rights reserved.
//

#import "SourceEditorCommand.h"

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation
                   completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
    
    NSInteger bracketStack = 0;
    NSInteger braceStack = 0;
    
    XCSourceTextRange *begin = invocation.buffer.selections.firstObject;
    XCSourceTextRange *end = invocation.buffer.selections.lastObject;
    
    XCSourceTextRange *range = [[XCSourceTextRange alloc] init];
    range.end = (XCSourceTextPosition){invocation.buffer.lines.count - 1, invocation.buffer.lines.lastObject.length};
    
    BOOL found = NO;
    
    for (NSInteger line = begin.start.line; !found && line >= 0; --line) {
        NSString *text = invocation.buffer.lines[line];
        NSInteger max = line == begin.start.line ? begin.start.column : text.length - 1;
        for (NSInteger col = max; !found && col >= 0; --col) {
            unichar ch = [text characterAtIndex:col];
            switch (ch) {
                case '[':
                    // Found
                    if (bracketStack == 0) {
                        range.start = (XCSourceTextPosition){line, col};
                        found = YES;
                    }
                    else {
                        --bracketStack;
                    }
                    break;
                case ']':
                    ++bracketStack;
                    break;
                case '{':
                    // Found
                    if (braceStack == 0) {
                        range.start = (XCSourceTextPosition){line, col};
                        found = YES;
                    }
                    else {
                        --braceStack;
                    }
                    break;
                case '}':
                    ++braceStack;
                    break;
                default:
                    break;
            }
        }
    }
    
    found = NO;
    braceStack = 0;
    bracketStack = 0;
    
    for (NSInteger line = end.end.line; !found && line < invocation.buffer.lines.count; ++line) {
        NSString *text = invocation.buffer.lines[line];
        NSInteger min = line == end.end.line ? end.end.column : 0;
        for (NSInteger col = min; !found && col < text.length; ++col) {
            unichar ch = [text characterAtIndex:col];
            switch (ch) {
                case ']':
                    // Found
                    if (bracketStack == 0) {
                        range.end = (XCSourceTextPosition){line, col + 1};
                        found = YES;
                    }
                    else {
                        --bracketStack;
                    }
                    break;
                case '[':
                    ++bracketStack;
                    break;
                case '}':
                    // Found
                    if (braceStack == 0) {
                        range.end = (XCSourceTextPosition){line, col + 1};
                        found = YES;
                    }
                    else {
                        --braceStack;
                    }
                    break;
                case '{':
                    ++braceStack;
                    break;
                default:
                    break;
            }
        }
    }
    
    [invocation.buffer.selections removeAllObjects];
    [invocation.buffer.selections addObject:range];
    
    completionHandler(nil);
}

@end
