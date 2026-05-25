import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

enum ActivityState {
    WORKOUT,
    WORKOUT_ALERT,
    WORKOUT_ALERT_RED,
    WORKOUT_OPEN_LAP,
    NAVIGATION,
    DISTANCE,
    DEFAULT
}

class TimerGauge extends WatchUi.Drawable {

    hidden var mTextColor as ColorValue = Graphics.COLOR_WHITE;
    hidden var mBorderColor as ColorValue = Graphics.COLOR_BLUE;
    hidden var mGaugeColor as ColorValue = Graphics.COLOR_DK_BLUE;

    hidden var mFontPrimary as FontType;
    hidden var mFontSecondary as FontType;

    hidden var mTextPrimary as String;
    hidden var mTextSecondary as String;
    hidden var mTextExtra1 as String or Null;
    hidden var mTextExtra2 as String or Null;
    hidden var mState as ActivityState;

    hidden var mRectWidth;
    hidden var mRectX;
    hidden var mXShift;
    hidden var mHeight1;
    hidden var mHeight2;
    hidden var mY1;
    hidden var mY2;

    function initialize() {
        Drawable.initialize({:identifier => "TimerGauge"});
        mFontPrimary = Graphics.FONT_NUMBER_THAI_HOT;
        mFontSecondary = Graphics.FONT_SMALL;
        mTextPrimary = "--:--";
        mTextSecondary = Properties.getValue("DefaultTag");
        mState = DEFAULT;
        updateStyle();
    }

    function setValues(textPrimary as String, textSecondary as String, textExtra1 as String or Null, textExtra2 as String or Null, state as ActivityState) as Void {
        mTextPrimary = textPrimary;
        mTextSecondary = textSecondary;
        mTextExtra1 = textExtra1;
        mTextExtra2 = textExtra2;
        mState = state;
        updateStyle();
    }

    function setAlignments(fontPrimary as FontType, fontSecondary as FontType, height1 as Number, height2 as Number, y1 as Number, y2 as Number, xShift as Number) {
        mFontPrimary = fontPrimary;
        mFontSecondary = fontSecondary;
        mHeight1 = height1;
        mHeight2 = height2;
        mY1 = y1;
        mY2 = y2;
        mXShift = xShift;
    }

    function draw(dc as Dc) as Void {
        var screenWidth = dc.getWidth();
        var minWidth = dc.getTextWidthInPixels("01234", mFontSecondary) * 1.5;
        var maxWidth = screenWidth * 0.75;
        mRectWidth = dc.getTextWidthInPixels(mTextSecondary, mFontSecondary) * 1.5;
        mRectWidth = mRectWidth > minWidth ? mRectWidth : minWidth;
        mRectWidth = mRectWidth < maxWidth ? mRectWidth : maxWidth;
        mRectX = (screenWidth / 2) - (mRectWidth / 2);
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(screenWidth / 2 + mXShift, mY2, mFontPrimary, mTextPrimary, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setPenWidth(4);
        dc.setColor(mGaugeColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(mRectX + mXShift, mY1, mRectWidth, mHeight1, 50);
        dc.setColor(mBorderColor, Graphics.COLOR_TRANSPARENT);
        dc.drawRoundedRectangle(mRectX + mXShift, mY1, mRectWidth, mHeight1, 50);
        dc.setColor(mTextColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(screenWidth / 2 + mXShift, mY1, mFontSecondary, mTextSecondary, Graphics.TEXT_JUSTIFY_CENTER);        
    }

    function updateStyle() {
        switch (mState) {
            case WORKOUT: {
                var seconds = System.getClockTime().sec;
                if (seconds % 5 > 1 || mTextExtra1 == null) {
                    mTextColor = Graphics.COLOR_WHITE;
                    mBorderColor = Graphics.COLOR_BLUE;
                    mGaugeColor = Graphics.COLOR_TRANSPARENT;
                } else {
                    if (seconds % 10 > 2 || mTextExtra2 == null) {
                        mTextSecondary = mTextExtra1;
                        mTextColor = Graphics.COLOR_WHITE;
                        mBorderColor = Graphics.COLOR_BLACK;
                        mGaugeColor = Graphics.COLOR_DK_GRAY;
                    } else {
                        mTextSecondary = mTextExtra2;
                        mTextColor = Graphics.COLOR_WHITE;
                        mBorderColor = Graphics.COLOR_DK_GREEN;
                        mGaugeColor = Graphics.COLOR_TRANSPARENT;
                    }
                }
                break;
            }
            case WORKOUT_ALERT: {
                mTextColor = Graphics.COLOR_WHITE;
                var seconds = System.getClockTime().sec;
                if (seconds % 2 > 0) {
                    mTextSecondary = Properties.getValue("WorkoutAlertReadyTag");
                    mBorderColor = Graphics.COLOR_WHITE;
                    mGaugeColor = Graphics.COLOR_DK_BLUE;
                } else {
                    mBorderColor = Graphics.COLOR_BLUE;
                    mGaugeColor = Graphics.COLOR_TRANSPARENT;
                }
                break;
            }
            case WORKOUT_ALERT_RED: {
                mTextColor = Graphics.COLOR_WHITE;
                var seconds = System.getClockTime().sec;
                if (seconds % 2 > 0) {
                    mTextSecondary = Properties.getValue("WorkoutRedAlertSetTag");
                    mBorderColor = Graphics.COLOR_RED;
                    mGaugeColor = Graphics.COLOR_DK_BLUE;
                } else {
                    mTextSecondary = Properties.getValue("WorkoutRedAlertGoTag");
                    mBorderColor = Graphics.COLOR_BLACK;
                    mGaugeColor = Graphics.COLOR_RED;
                }
                break;
            }
            case WORKOUT_OPEN_LAP: {
                var seconds = System.getClockTime().sec;
                if (seconds % Properties.getValue("OpenLapDisplayInSeconds") > 0) {
                    mTextColor = Graphics.COLOR_BLACK;
                    mBorderColor = Graphics.COLOR_BLACK;
                    mGaugeColor = Graphics.COLOR_YELLOW;
                } else {
                    mTextSecondary = Properties.getValue("OpenLapTag");;
                    mTextColor = Graphics.COLOR_WHITE;
                    mBorderColor = Graphics.COLOR_YELLOW;
                    mGaugeColor = Graphics.COLOR_TRANSPARENT;
                }
                break;
            }
            case NAVIGATION: {
                var seconds = System.getClockTime().sec; 
                if (seconds % 5 > 1) {
                    mTextColor = Graphics.COLOR_WHITE;
                    mBorderColor = Graphics.COLOR_DK_GREEN;
                    mGaugeColor = Graphics.COLOR_TRANSPARENT;
                } else {
                    mBorderColor = Graphics.COLOR_BLACK;
                    if (seconds % 10 > 2 || mTextExtra2 == null) {
                        mTextSecondary = mTextExtra1;
                        mTextColor = Graphics.COLOR_BLACK;
                        mGaugeColor = Graphics.COLOR_DK_GREEN;
                    } else {
                        mTextSecondary = mTextExtra2;
                        mTextColor = Graphics.COLOR_WHITE;
                        mGaugeColor = Graphics.COLOR_DK_GRAY;
                    }
                }
                break;
            }
            case DISTANCE: {
                mTextColor = Graphics.COLOR_LT_GRAY;
                mBorderColor = Graphics.COLOR_DK_GRAY;
                mGaugeColor = Graphics.COLOR_TRANSPARENT;
                break;
            }
            default: {
                mTextSecondary = Properties.getValue("DefaultTag");
                mTextColor = Graphics.COLOR_WHITE;
                mBorderColor = Graphics.COLOR_TRANSPARENT;
                mGaugeColor = Graphics.COLOR_TRANSPARENT;
                break;
            }
        }
    }

}