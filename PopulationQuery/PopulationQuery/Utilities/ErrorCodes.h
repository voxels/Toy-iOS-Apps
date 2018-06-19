//
//  ErrorCodes.h
//  PopulationQuery
//
//  Copyright © 2018 Michael Edgcumbe. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef ErrorCodes_h
#define ErrorCodes_h

static NSString *const AppErrorDomain = @"com.secretatomics.populationquery.errordomain";

typedef NS_ERROR_ENUM(AppErrorDomain, InternalError) {
    unknownCode = -10000,
    parsingErrorCode,
    loadStoreErrorCode,
    fetchStoreErrorCode,
    duplicateEntryErrorCode,
};

#endif /* ErrorCodes_h */
