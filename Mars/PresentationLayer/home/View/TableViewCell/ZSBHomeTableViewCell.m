//
//  ZSBHomeTableViewCell.m
//  Mars
//
//  Created by zhaoqin on 6/16/16.
//  Copyright © 2016 Muggins_. All rights reserved.
//

#import "ZSBHomeTableViewCell.h"
#import "ZSBKnowledgeModel.h"
#import "ZSBTestModel.h"

NSString *const ZSBHomeTableViewCellIdentifier = @"ZSBHomeTableViewCell";

@implementation ZSBHomeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadTestModel:(ZSBTestModel *)model {

    [self.image sd_setImageWithURL:[NSURL URLWithString:model.imageURL] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    self.titleLabel.text = model.title;
    self.countLabel.text = [NSString stringWithFormat:@"%@人参加", model.participateCount];

    [self resumeLabel];

    NSInteger count = 1;
    if (![model.tag1 isEqualToString:@""]) {
        UILabel *label = [self.contentView viewWithTag:count++];
        label.text = model.tag1;
    }
    if (![model.tag2 isEqualToString:@""]) {
        UILabel *label = [self.contentView viewWithTag:count++];
        label.text = model.tag2;
    }
    if (![model.tag3 isEqualToString:@""]) {
        UILabel *label = [self.contentView viewWithTag:count++];
        label.text = model.tag3;
    }
    if (![model.tag3 isEqualToString:@""]) {
        UILabel *label = [self.contentView viewWithTag:count++];
        label.text = model.tag3;
    }
    while (count < 5) {
        UILabel *label = [self.contentView viewWithTag:count++];
        label.hidden = YES;
    }
}

- (void)loadKnowledgeModel:(ZSBKnowledgeModel *)model {

    [self.image sd_setImageWithURL:[NSURL URLWithString:model.imageURL] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    self.titleLabel.text = model.title;
    self.countLabel.text = [NSString stringWithFormat:@"%@人参加", model.participateCount];

    [self resumeLabel];

    NSInteger count = 1;
    if (![model.tag1 isEqualToString:@""]) {
        UILabel *label = [self.contentView viewWithTag:count++];
        label.text = model.tag1;
    }
    if (![model.tag2 isEqualToString:@""]) {
        UILabel *label = [self.contentView viewWithTag:count++];
        label.text = model.tag2;
    }
    if (![model.tag3 isEqualToString:@""]) {
        UILabel *label = [self.contentView viewWithTag:count++];
        label.text = model.tag3;
    }
    if (![model.tag3 isEqualToString:@""]) {
        UILabel *label = [self.contentView viewWithTag:count++];
        label.text = model.tag3;
    }
    while (count < 5) {
        UILabel *label = [self.contentView viewWithTag:count++];
        label.hidden = YES;
    }
}

- (void)resumeLabel {
    self.tag1Label.hidden = NO;
    self.tag2Label.hidden = NO;
    self.tag3Label.hidden = NO;
    self.tag4Label.hidden = NO;
}

@end
