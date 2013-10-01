//
//  CategoryButtons.h
//  Shoestring
//
//  Created by mark on 29/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol CategoryButtonsDelegate;


@interface CategoryButtons : UIView

@property (strong, nonatomic) NSString *currentCategory;
@property (strong, nonatomic) NSArray *categoryNames;
@property (strong, nonatomic) NSMutableArray *buttons;
@property (strong, nonatomic) UILabel *categoryLabel;
    
-(void) setButtonSelected: (int) button;

@property (assign,nonatomic) NSObject <CategoryButtonsDelegate> *delegate;

@end


//declare the delegate protocol method to listen for the changed category
@protocol CategoryButtonsDelegate

-(void) buttonView: (CategoryButtons*) buttonView changedCategory: (NSString*)newCategory;

@end

