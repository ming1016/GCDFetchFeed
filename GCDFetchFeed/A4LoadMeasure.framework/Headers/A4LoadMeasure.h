//
//  A4LoadMeasure.h
//  A4LoadMeasure
//
//  Created by tripleCC on 5/22/19.
//  Copyright © 2019 tripleCC. All rights reserved.
//

#ifndef A4LoadMeasure_h
#define A4LoadMeasure_h

#import <Foundation/Foundation.h>

@interface LMLoadInfo : NSObject
@property (copy, nonatomic, readonly) NSString *clsname;
@property (copy, nonatomic, readonly) NSString *catname;
@property (assign, nonatomic, readonly) CFAbsoluteTime start;
@property (assign, nonatomic, readonly) CFAbsoluteTime end;
@property (assign, nonatomic, readonly) CFAbsoluteTime duration;
@end

@interface LMLoadInfoWrapper : NSObject
@property (assign, nonatomic, readonly) Class cls;
@property (copy, nonatomic, readonly) NSArray <LMLoadInfo *> *infos;
@end

extern NSArray <LMLoadInfoWrapper *> *LMLoadInfoWappers;

#endif /* A4LoadMeasure_h */
