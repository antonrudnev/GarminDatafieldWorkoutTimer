import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

enum ActivityState {
    DEFAULT             = 1,
    DISTANCE            = 2,
    NAVIGATION          = 4,
    WORKOUT             = 8,
    WORKOUT_ALERT       = 16,
    WORKOUT_ALERT_RED   = 32,
    WORKOUT_OPEN_LAP    = 64
}

class TimerGauge extends WatchUi.Drawable {

    hidden var mTextColor as ColorValue = Graphics.COLOR_WHITE;
    hidden var mBorderColor as ColorValue = Graphics.COLOR_BLUE;
    hidden var mGaugeColor as ColorValue = Graphics.COLOR_DK_BLUE;

    hidden var mBackground as ColorValue = Graphics.COLOR_BLACK;
    hidden var mForeground as ColorValue = Graphics.COLOR_WHITE;

    hidden var mFontPrimary as FontType;
    hidden var mFontSecondary as FontType;

    hidden var mTextPrimary as String;
    hidden var mTextSecondary as String;
    hidden var mTextExtra1 as String or Null;
    hidden var mTextExtra2 as String or Null;
    hidden var mState;

    hidden var mRectWidth;
    hidden var mRectX;
    hidden var mXShift;
    hidden var mHeight1;
    hidden var mHeight2;
    hidden var mY1;
    hidden var mY2;
    hidden var mExpandable;

    hidden var isExpanded = false;

    function initialize() {
        Drawable.initialize({:identifier => "TimerGauge"});
        mFontPrimary = Graphics.FONT_NUMBER_THAI_HOT;
        mFontSecondary = Graphics.FONT_SMALL;
        mTextPrimary = "--:--";
        mTextSecondary = Properties.getValue("DefaultTag");
        mState = DEFAULT;
        updateStyle();
    }

    function setBackground(background as ColorValue) {
        mBackground = background;
        if (mBackground == Graphics.COLOR_BLACK) {
            mForeground = Graphics.COLOR_WHITE;
        } else {
            mForeground = Graphics.COLOR_BLACK;
        }
        mTextColor = mForeground;
    }

    function setValues(textPrimary as String, textSecondary as String, textExtra1 as String or Null, textExtra2 as String or Null, state as Number) as Void {
        mTextPrimary = textPrimary;
        mTextSecondary = textSecondary;
        mTextExtra1 = textExtra1;
        mTextExtra2 = textExtra2;
        mState = state;
        updateStyle();
    }

    function setAlignments(fontPrimary as FontType, fontSecondary as FontType, height1 as Number, height2 as Number, y1 as Number, y2 as Number, xShift as Number, expandable as Boolean) {
        mFontPrimary = fontPrimary;
        mFontSecondary = fontSecondary;
        mHeight1 = height1;
        mHeight2 = height2;
        mY1 = y1;
        mY2 = y2;
        mXShift = xShift;
        mExpandable = expandable;
    }

    function swapHeights() as Void {
        if (mExpandable) {
            var z = mFontPrimary;
            mFontPrimary = mFontSecondary;
            mFontSecondary = z;
            z = mHeight1;
            mHeight1 = mHeight2;
            mHeight2 = z;
            mY2 = mY1 + mHeight1;
            isExpanded = !isExpanded;
        }
    }

    function draw(dc as Dc) as Void {
        var screenWidth = dc.getWidth();
        var minWidth = dc.getTextWidthInPixels("01234", mFontSecondary) * 1.5;
        var maxWidth = screenWidth * 0.75;
        mRectWidth = dc.getTextWidthInPixels(mTextSecondary, mFontSecondary) * 1.5;
        mRectWidth = mRectWidth > minWidth ? mRectWidth : minWidth;
        mRectWidth = mRectWidth < maxWidth ? mRectWidth : maxWidth;
        mRectX = (screenWidth / 2) - (mRectWidth / 2);

        dc.setColor(mForeground, mBackground);
        dc.clear();

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
        if (isExpanded) {
            swapHeights();
        }
        var seconds = System.getClockTime().sec;
        if (mState & WORKOUT != 0) {
            if (mState & WORKOUT_ALERT_RED != 0) {
                mTextColor = Graphics.COLOR_WHITE;
                if (seconds & 1) {
                    mTextSecondary = Properties.getValue("WorkoutRedAlertSetTag");
                    mBorderColor = Graphics.COLOR_RED;
                    mGaugeColor = Graphics.COLOR_DK_BLUE;
                } else {
                    mTextSecondary = Properties.getValue("WorkoutRedAlertGoTag");
                    mBorderColor = mBackground;
                    mGaugeColor = Graphics.COLOR_RED;
                }
                return;
            } else if (mState & WORKOUT_ALERT != 0) {
                if (seconds & 1) {
                    mTextSecondary = Properties.getValue("WorkoutAlertReadyTag");
                    mTextColor = Graphics.COLOR_WHITE;
                    mBorderColor = mForeground;
                    mGaugeColor = Graphics.COLOR_DK_BLUE;
                } else {
                    mTextColor = mForeground;
                    mBorderColor = Graphics.COLOR_BLUE;
                    mGaugeColor = mBackground;
                }
                return;
            } else if (mState & WORKOUT_OPEN_LAP != 0) {
                if (seconds % Properties.getValue("OpenLapDisplayInSeconds") > 0) {
                    mTextColor = Graphics.COLOR_BLACK;
                    mBorderColor = mBackground;
                    mGaugeColor = Graphics.COLOR_YELLOW;
                } else {
                    mTextSecondary = Properties.getValue("OpenLapTag");;
                    mTextColor = mForeground;
                    mBorderColor = Graphics.COLOR_YELLOW;
                    mGaugeColor = mBackground;
                }
            } else {
                if (seconds % 5 > 1 || mState & DISTANCE == 0) {
                    mTextColor = mForeground;
                    mBorderColor = Graphics.COLOR_BLUE;
                    mGaugeColor = mBackground;
                } else {
                    if (!isExpanded) {
                        swapHeights();
                    }
                    if (seconds % 10 > 2) {
                        mTextSecondary = mTextExtra1;
                        if (mState & NAVIGATION != 0) {
                            mTextColor = mForeground;
                            mBorderColor = Graphics.COLOR_DK_GREEN;
                            mGaugeColor = mBackground;
                        } else {
                            mTextColor = Graphics.COLOR_BLACK;
                            mBorderColor = mBackground;
                            mGaugeColor = Graphics.COLOR_BLUE;
                        }
                    } else {
                        mTextSecondary = mTextExtra2;
                        mTextColor = Graphics.COLOR_WHITE;
                        mBorderColor = mBackground;
                        mGaugeColor = Graphics.COLOR_DK_GRAY;
                    }
                }
            }
        } else if (mState & NAVIGATION != 0) {
            if (seconds % 5 > 1) {
                mTextColor = mForeground;
                mBorderColor = Graphics.COLOR_DK_GREEN;
                mGaugeColor = mBackground;
            } else {
                if (!isExpanded) {
                    swapHeights();
                }
                mBorderColor = mBackground;
                if (seconds % 10 > 2) {
                    mTextSecondary = mTextExtra1;
                    mTextColor = Graphics.COLOR_BLACK;
                    mGaugeColor = Graphics.COLOR_DK_GREEN;
                } else {
                    mTextSecondary = mTextExtra2;
                    mTextColor = Graphics.COLOR_WHITE;
                    mGaugeColor = Graphics.COLOR_DK_GRAY;
                }
            }
        } else if (mState & DISTANCE != 0) {
            if (seconds % 5 > 1) {
                mTextColor = Graphics.COLOR_WHITE;
                mBorderColor = mBackground;
                mGaugeColor = Graphics.COLOR_DK_GRAY;
            } else {
                if (!isExpanded) {
                    swapHeights();
                }
                mTextSecondary = mTextExtra1;
                mTextColor = mForeground;
                mBorderColor = Graphics.COLOR_DK_RED;
                mGaugeColor = mBackground;
            }
        } else {
            mTextSecondary = Properties.getValue("DefaultTag");
            mTextColor = mForeground;
            mBorderColor = mBackground;
            mGaugeColor = mBackground;
        }
    }

}