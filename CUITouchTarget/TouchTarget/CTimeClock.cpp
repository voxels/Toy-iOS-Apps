//
//  CTimeClock.cpp
//  TouchTarget
//
//  Created by Voxels on 1/12/17.
//  Copyright © 2017 Noise Derived. All rights reserved.
//

#include "CTimeClock.hpp"
#include <chrono>

// Returns the number of seconds since January 1st, 2001

using namespace std::chrono;

double CTimeClock::GetCurrentTime(){
    high_resolution_clock::time_point t1 = high_resolution_clock::now();
    duration<double> time_span = duration_cast<duration<double>>(t1.time_since_epoch());;
    return time_span.count();
}
