//
//  CUITouchTarget.hpp
//  TouchTarget
//
//  Created by Voxels on 1/12/17.
//  Copyright © 2017 Noise Derived. All rights reserved.
//

#ifndef CUITouchTarget_hpp
#define CUITouchTarget_hpp

#include <stdio.h>
#import <time.h>

#define kDoubleTapTouchTimeInterval     0.500	 // This is half a second.
#define kTouchTargetThreshhold          0.025    // normalized distance that passes through a successful touch event

struct CUIPoint
{
    float xPos;
    float yPos;
};

struct CUITouch
{
    double time;
    CUIPoint point;
};


struct CUITouchEvent
{
    bool candidate;
    CUITouch touch;
};

enum CUITouchState {
    Possible,
    Began,
    Changed,
    Ended,
    Failed
};

class CUITouchTarget
{
public:
    CUITouchTarget();
    void OnTouchBegan(const CUIPoint& pos, unsigned long len);
    void OnTouchEnded(const CUIPoint& pos, unsigned long len);
    void OnTouchCancelled();
    void SendDoubleTapNotification();
private:
    CUITouchState   m_state;
    CUITouch        m_beginTouch;
    CUITouchEvent   m_lastEvent;
    
    bool validTouchLength(unsigned long len);
    bool validTime(CUITouch & touch);
    bool validDistance(const CUIPoint & beginPos, const CUIPoint & endPos);
    bool validPoint(CUITouch & touch);
    void updateCandidate(CUITouchEvent & event);
    bool confirmCandidate(const CUIPoint & pos);
//    bool confirmEvent();
    void resetState();
    static CUIPoint invalidPoint();
};

#endif /* CUITouchTarget_hpp */
