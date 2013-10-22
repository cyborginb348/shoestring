//
//  CategoryButtons.m
//  Shoestring
//
//  Created by mark on 29/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import "CategoryButtons.h"

@interface CategoryButtons ()

-(CategoryButtons*) init;
-(void) notifyDelegate;

@end

@implementation CategoryButtons

@synthesize currentCategory, categoryNames, buttons, categoryLabel;

@synthesize delegate = _delegate;

-(CategoryButtons*) init {
    
    //initialise button arrays for the button objects and names
    categoryNames = [[NSArray alloc] initWithObjects:@"Accommodation", @"Food", @"Travel", @"Entertainment", @"Shopping", nil];
    
    self = [self initWithFrame:CGRectMake(10, 10, 300, 300)];
    
    //the images
    UIImage *accomImage = [UIImage imageNamed:@"accommodation.png"];
    UIImage *foodImage = [UIImage imageNamed:@"food.png"];
    UIImage *travelImage = [UIImage imageNamed:@"travel.png"];
    UIImage *entertainImage = [UIImage imageNamed:@"entertainment.png"];
    UIImage *shopImage = [UIImage imageNamed:@"shopping.png"];
    UIImage *accomImageSel = [UIImage imageNamed:@"accommodation_sel.png"];
    UIImage *foodImageSel = [UIImage imageNamed:@"food_sel.png"];
    UIImage *travelImageSel = [UIImage imageNamed:@"travel_sel.png"];
    UIImage *entertainImageSel = [UIImage imageNamed:@"entertainment_sel.png"];
    UIImage *shopImageSel = [UIImage imageNamed:@"shopping_sel.png"];
    
    //the images in arrays
    NSArray *btnImgs = [[NSArray alloc]initWithObjects:accomImage,foodImage,travelImage,entertainImage,shopImage,nil];
    NSArray *btnImgs_sel = [[NSArray alloc]initWithObjects:accomImageSel,foodImageSel,travelImageSel,entertainImageSel,shopImageSel, nil];
    
    //make the buttons
    buttons = [[NSMutableArray alloc] init];
    UIButton *btn;
    float xAxis = 0;
    
    for(int i = 0; i < 5 ; i++) {
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(0, 0, 55.0, 55.0)];
        [btn setBackgroundImage:[btnImgs objectAtIndex:i] forState:UIControlStateNormal];
        [btn setBackgroundImage:[btnImgs_sel objectAtIndex:i] forState:UIControlStateHighlighted];
        [btn setBackgroundImage:[btnImgs_sel objectAtIndex:i] forState:UIControlStateSelected];
        [btn setTag:i];
        [buttons addObject:btn]; //add to array
        [btn addTarget:self
                action:@selector(changeSelection:)
      forControlEvents: UIControlEventTouchUpInside];
        [btn setFrame:CGRectMake(xAxis, 0, 55.0, 55.0)];
        [self insertSubview:btn atIndex:i];

        xAxis += 60;
    }
    //ste up the title to display the category
    categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 300, 50)];
    [categoryLabel setTextColor: [UIColor colorWithRed:19.0f/255 green:44.0f/255 blue:68.0f/255 alpha:1]];
    [categoryLabel setFont:[UIFont boldSystemFontOfSize:30]];
    [categoryLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:categoryLabel];
    
    
    return self;
}

#pragma mark - Button Actions

//Method: change selection of current button
-(void) changeSelection:(UIButton*) currentBtn {
    
    [categoryLabel setText:@""];
    
    /*if(currentBtn.selected == NO) {*/
        [currentBtn setSelected:YES];
        [categoryLabel setText:[categoryNames objectAtIndex: [currentBtn tag]]];
        [self setButtonsUnselected:currentBtn]; //set all buttons unselected except current
        currentCategory = [categoryNames objectAtIndex: [currentBtn tag]];
        [self notifyDelegate];
    /*} else {
        [currentBtn setSelected:NO];
    }*/
    
}

//Method to select an image
-(void) setButtonSelected: (int) buttonTag {
   [[buttons objectAtIndex: buttonTag] setSelected:YES];
    [categoryLabel setText:[categoryNames objectAtIndex:buttonTag]];
}


//Method: set all buttons except current as unselected
-(void) setButtonsUnselected:(UIButton *)currentBtn {
    
    for (UIButton *btn in buttons) {
        if(btn.tag != currentBtn.tag) {
            [btn setSelected:NO];
        }
    }
}

-(void) setCategoryTitle: (NSString*) title{
    [categoryLabel setText:title];
}



-(void)notifyDelegate {
    
    if([self delegate] && [[self delegate] respondsToSelector:@selector(buttonView:changedCategory:)]) {
        [[self delegate] performSelector:@selector(buttonView:changedCategory:)
                              withObject: currentCategory];
    }
}

@end
