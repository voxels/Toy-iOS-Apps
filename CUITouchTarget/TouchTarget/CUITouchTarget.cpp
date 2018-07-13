//
//  CUITouchTarget.cpp
//  TouchTarget
//
//  Created by Voxels on 1/12/17.
//  Copyright © 2017 Noise Derived. All rights reserved.
//

#include "CUITouchTarget.hpp"
#include "CTimeClock.hpp"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>


/*
// Right now we are resetting state immediately after failure.  It may be that you want to make a new
// instance and keep the failed state in some use cases.
*/

CUITouchTarget::CUITouchTarget()
{
    resetState();
}

// This will be called when the user places a finger down on this control.
// pos is the on screen position where the user touched.
void CUITouchTarget::OnTouchBegan(const CUIPoint& pos, unsigned long len)
{
#if DEBUG
    printf("On touch Began: state is %i\nPosition is x: %f\ty: %f\n\n", m_state, pos.xPos, pos.yPos);
#endif
    
    if( !validTouchLength(len) )
    {
#if DEBUG
        printf("Tap target events are only valid for 1 touch.  Received %lu touches.\n", len);
#endif

        m_state = Failed;
        resetState();
        return;
    }
    
    switch ( m_state )
    {
        case Possible:
            m_beginTouch.point = pos;
            m_beginTouch.time = CTimeClock::GetCurrentTime();
            m_state = Began;
            break;
        case Began:
            if( m_beginTouch.time > 0 && validTime(m_beginTouch) )
            {
                m_beginTouch.point = pos;
                m_beginTouch.time = CTimeClock::GetCurrentTime();
                m_state = Changed;
            }
            else
            {
#if DEBUG
                printf("Previous touch was too long ago.  Starting over\n");
#endif
                resetState();
                m_beginTouch.point = pos;
                m_beginTouch.time = CTimeClock::GetCurrentTime();
                m_state = Began;
            }
            break;
        case Changed:
        case Ended:
        case Failed:
#if DEBUG
            printf("Received touch began while state is %i.  Resetting state.\n", m_state);
#endif
            resetState();
            m_beginTouch.point = pos;
            m_beginTouch.time = CTimeClock::GetCurrentTime();
            m_state = Began;
            break;
    }
}

// This will be called when the user releases the finger previously placed on this control.
// pos is the on screen position where the user released.
void CUITouchTarget::OnTouchEnded(const CUIPoint& pos, unsigned long len)
{
#if DEBUG
    printf("On touch Ended : state is %i\nPosition is x: %f\ty: %f\n\n", m_state, pos.xPos, pos.yPos);
#endif
    
    if( !validTouchLength(len) )
    {
#if DEBUG
        printf("Tap target events are only valid for 1 touch.  Received %lu touches.\n", len);
#endif
        
        m_state = Failed;
        resetState();
        return;
    }
    
    if( m_beginTouch.point.xPos < 0 || m_beginTouch.point.yPos < 0 || m_beginTouch.time == 0 )
    {
#if DEBUG
        printf("beginTouch was not initialized before touch ended.  State is FAILED\n");
#endif
        
        m_state = Failed;
    }
    
    if( !validDistance(m_beginTouch.point, pos) )
    {
#if DEBUG
        printf("Distance was too far for valid tap.  State is FAILED\n");
#endif

        m_state = Failed;
    }
    
    if( !validTime(m_beginTouch))
    {
#if DEBUG
        printf("Time was too long for valid tap.  State is FAILED\n");
#endif
        
        m_state = Failed;
    }

    switch ( m_state )
    {
        case Possible:
            printf("Error: 'POSSIBLE' state on touch ended. Should not reach this point.\n");
            // Throw exception
            abort();
        case Began:
#if DEBUG
            printf("Checking for candidate\n");
#endif
            if( m_lastEvent.candidate == false )
            {
#if DEBUG
                printf("Candidate does not exist.  Updating with location.\n");
#endif
                CUITouch endPoint = { CTimeClock::GetCurrentTime(), pos };
                CUITouchEvent event = { true, endPoint };
                updateCandidate(event);
            }
            else
            {
#if DEBUG
                printf("Error: Found existing candidate while in the 'BEGAN' state.  Should not reach this point");
#endif
                // Throw exception
                abort();
            }
            break;
        case Changed:
#if DEBUG
            printf("Candidate exists.  Ready to confirm.\n");
#endif
            if( confirmCandidate(pos) )
            {
                m_state = Ended;
                SendDoubleTapNotification();
            }
            else
            {
#if DEBUG
                printf("Candidate did not pass validation\n");
#endif
                m_state = Failed;
                resetState();
            }
            break;
        case Ended:
#if DEBUG
            printf("Error: 'ENDED' state on touch ended.  Should not reach this point.\n");
#endif
            // Throw exception
            abort();
        case Failed:
#if DEBUG
            printf("Gesture has already failed at a previous point.  Resetting state.\n");
#endif
            resetState();
            break;
    }
}

void CUITouchTarget::OnTouchCancelled()
{
    resetState();
}


void CUITouchTarget::SendDoubleTapNotification()
{
    printf("D-DOUBLE Tap\n");
}

// MARK: - State

CUIPoint CUITouchTarget::invalidPoint()
{
    return {-1.0, -1.0};
}

void CUITouchTarget::resetState()
{
#if DEBUG
    printf("::::::RESET STATE::::::\n\n\n\n\n");
#endif
    
    m_state = Possible;
    m_beginTouch.time = -1;
    m_beginTouch.point = invalidPoint();
    m_lastEvent.candidate = false;
    m_lastEvent.touch.time = -1;
    m_lastEvent.touch.point = invalidPoint();
}

void CUITouchTarget::updateCandidate(CUITouchEvent & event)
{
    m_lastEvent = event;
}


// MARK: - Validation

bool CUITouchTarget::validTouchLength(unsigned long len)
{
    if( len == 1 )
    {
        return true;
    }
    
    return false;
}

bool CUITouchTarget::validTime(CUITouch & touch)
{
    double currentTime = CTimeClock::GetCurrentTime();
    double diff = fabs(currentTime - touch.time);
    
    if( diff < kDoubleTapTouchTimeInterval  && currentTime > touch.time )
    {
        return true;
    }
    
    return false;
}

bool CUITouchTarget::validDistance(const CUIPoint &beginPos, const CUIPoint &endPos)
{
    float xDiff = fabs(beginPos.xPos - endPos.xPos);
    float yDiff = fabs(beginPos.yPos - endPos.yPos);
    
    if( xDiff < kTouchTargetThreshhold && yDiff < kTouchTargetThreshhold )
    {
        return true;
    }
    
    return false;
}
 
bool CUITouchTarget::confirmCandidate(const CUIPoint & pos)
{
    if( !validDistance(pos, m_lastEvent.touch.point))
    {
#if DEBUG
        printf("Candidate distance was too far\n");
#endif
        return false;
    }
    
    if( !validTime( m_lastEvent.touch ) )
    {
#if DEBUG
        printf("Candidate time was too long\n");
#endif
        return false;
    }

#if DEBUG
    printf("Candidate PASSED\n");
#endif
    
    return true;
}

