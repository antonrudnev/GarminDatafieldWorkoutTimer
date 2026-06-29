import Toybox.Activity;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class WorkoutTimerProDataFieldView extends WatchUi.DataField {

    hidden var mActivityState = DEFAULT;
    hidden var mActivityTimer = 0;
    hidden var mActivityDistance = 0.0;
    hidden var mWorkoutStepTimer = 0;
    hidden var mWorkoutPrevStepCompleteTime = 0;
    hidden var mDistanceToComplete = 0.0;
    hidden var mDistanceToDestination = 0.0;
    hidden var mTimeToDestination = 0;
    hidden var phoneConnected = false;

    function initialize() {
        DataField.initialize();
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc as Dc) as Void {
        View.setLayout(Rez.Layouts.MainLayout(dc));
        var timerGauge = View.findDrawableById("TimerGauge") as TimerGauge;
        var alignments = computeAlignments(dc);
        timerGauge.setAlignments(alignments[0], alignments[1], alignments[2], alignments[3], alignments[4], alignments[5], alignments[6], alignments[7]);
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Void {
        mActivityState = DEFAULT;
        if (info.timerTime != null && info.elapsedDistance != null) {
            mActivityTimer = (info.timerTime / 1000).toNumber();
            mActivityDistance = info.elapsedDistance;
            if (mActivityDistance >= Properties.getValue("MinDistanceToActivate")) {
                mActivityState = DISTANCE;
                mDistanceToDestination = 0;
                mTimeToDestination = 0;
                if (info has :distanceToDestination && info has :offCourseDistance
                            && info.distanceToDestination != null && info.offCourseDistance != null && info.averageSpeed != null
                            && info.averageSpeed > 0 && info.distanceToDestination > 0
                            && info.offCourseDistance < Properties.getValue("AllowedOffCourseDistance")) {
                        mActivityState = mActivityState | NAVIGATION;
                        mDistanceToDestination = info.distanceToDestination;
                        mTimeToDestination = (mDistanceToDestination / info.averageSpeed).toNumber();
                }
                if (Properties.getValue("ShowPhoneAlert")) {
                    if (System.getDeviceSettings().phoneConnected) {
                    phoneConnected = true;
                    } else if (phoneConnected) {
                        mActivityState = mActivityState | PHONE_ALERT;
                    }
                }
            } 
            var workoutStepInfo = Activity.getCurrentWorkoutStep();
            if (workoutStepInfo != null) {
                mActivityState = mActivityState | WORKOUT;
                var workoutStep = workoutStepInfo.step;
                if (workoutStep instanceof Activity.WorkoutIntervalStep) {
                    workoutStep = workoutStep.activeStep;
                }
                mWorkoutStepTimer = mActivityTimer - mWorkoutPrevStepCompleteTime;
                if (workoutStep.durationType == Activity.WORKOUT_STEP_DURATION_TIME) {
                    if (workoutStep.durationValue != null) {
                        mWorkoutStepTimer = (workoutStep.durationValue - mWorkoutStepTimer).toNumber();
                        if (info.averageSpeed != null) {
                            mDistanceToComplete = mWorkoutStepTimer * info.averageSpeed;
                            System.println(mDistanceToComplete.toString() + "m, " + info.averageSpeed.toString() + "mps");
                        }
                        if (mWorkoutStepTimer < Properties.getValue("WorkoutAlertTheshold")) {
                            mActivityState = mActivityState | WORKOUT_ALERT;
                        }
                        if (mWorkoutStepTimer < Properties.getValue("WorkoutRedAlertTheshold")) {
                            mActivityState = mActivityState | WORKOUT_ALERT_RED;
                        }
                    }
                } else if (workoutStep.durationType == Activity.WORKOUT_STEP_DURATION_OPEN) {
                    mActivityState = mActivityState | WORKOUT_OPEN_LAP;
                }
            }
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        var timerGauge = View.findDrawableById("TimerGauge") as TimerGauge;
        if (mActivityState & WORKOUT != 0) {
            timerGauge.setValues(formatTime(mWorkoutStepTimer, mActivityState & WORKOUT_ALERT !=0 || mActivityState & WORKOUT_ALERT_RED !=0), formatTime(mActivityTimer, false), mActivityState & NAVIGATION !=0 ? formatTime(mTimeToDestination, false) : formatDistance(mDistanceToComplete), formatDistance(mActivityDistance), mActivityState);
        } else if (mActivityState & NAVIGATION !=0) {
            timerGauge.setValues(formatTime(mActivityTimer, false), formatTime(mTimeToDestination, false), formatDistance(mDistanceToDestination), formatDistance(mActivityDistance), mActivityState);
        } else {
            timerGauge.setValues(formatTime(mActivityTimer, false), formatDistance(mActivityDistance), format("$1$:$2$", [System.getClockTime().hour.format("%02d"), System.getClockTime().min.format("%02d")]), null, mActivityState);
        }
        View.onUpdate(dc);
    }

    function onWorkoutStepComplete() as Void {
        var activityInfo = Activity.getActivityInfo();
        if (activityInfo != null && activityInfo.timerTime != null) {
            mWorkoutPrevStepCompleteTime = (activityInfo.timerTime / 1000).toNumber();
        }
    }

    function formatTime(seconds as Number, secOnly as Boolean) as String {
        var hrs = seconds / 3600;
        var mins = (seconds % 3600) / 60;
        var secs = seconds % 60;
        if (hrs > 0) {
            return format("$1$:$2$:$3$", [hrs.format("%1d"), mins.format("%02d"), secs.format("%02d")]);
        } else if (mins > 0 || !secOnly) {
            return format("$1$:$2$", [mins.format("%1d"), secs.format("%02d")]);
        } else {
            return format("$1$", [secs.format("%1d")]);
        }
    }

    function formatDistance(meters as Float) as String {
        if (meters < 1000 ) {
            return (meters.toNumber() / 10 * 10).format("%1d") + " m";
        } else {
            if ((meters / 100).toNumber() % 10 == 0) {
                return (meters / 1000).toNumber() + " KM";
            } else {
                return (meters / 1000).format("%.1f") + " K";
            }
        }
    }

    function computeAlignments(dc as Dc) as [FontType, FontType, Number, Number, Number, Number, Number, Boolean] {
        var fontPrimary = Graphics.FONT_NUMBER_THAI_HOT;
        var fontSecondary = Graphics.FONT_SMALL;
        var screenHeight = dc.getHeight();
        var height1 = dc.getFontHeight(fontSecondary);
        var height2 = dc.getFontHeight(fontPrimary);
        var flag = false;
        while (height1 + height2 > screenHeight) {
            if (flag) {
                fontSecondary = (fontSecondary > 0 ? fontSecondary - 1 : 0) as FontType;
            } else
            {
                fontPrimary = (fontPrimary > 0 ? fontPrimary - 1 : 0) as FontType;
            }
            flag = !flag;
            height1 = dc.getFontHeight(fontSecondary);
            height2 = dc.getFontHeight(fontPrimary);
        }     
        var screenWidth = dc.getWidth();
        while (screenWidth < dc.getTextWidthInPixels("00:00:00", fontPrimary)) {
            fontPrimary = (fontPrimary > 0 ? fontPrimary - 1 : 0) as FontType;
        }
        while (screenWidth < dc.getTextWidthInPixels("00:00:00", fontSecondary) * 1.5) {
            fontSecondary = (fontSecondary > 0 ? fontSecondary - 1 : 0) as FontType;
        }
        height1 = dc.getFontHeight(fontSecondary);
        height2 = dc.getFontHeight(fontPrimary);
        var obscurityFlags = DataField.getObscurityFlags();
        var xShift = 0;
        if (obscurityFlags & OBSCURE_LEFT != 0 && obscurityFlags & OBSCURE_RIGHT == 0) {
            xShift = dc.getTextWidthInPixels("0", fontSecondary);
        } else if (obscurityFlags & OBSCURE_RIGHT != 0 && obscurityFlags & OBSCURE_LEFT == 0) {
            xShift = -dc.getTextWidthInPixels("0", fontSecondary);
        }
        var y1;
        var y2;
        var expandable = true;
        if (obscurityFlags & OBSCURE_TOP != 0 && obscurityFlags & OBSCURE_BOTTOM == 0) {
            y2 = screenHeight - height2;
            y1 = y2 - height1;
            expandable = false;
        } else if (obscurityFlags & OBSCURE_BOTTOM != 0 && obscurityFlags & OBSCURE_TOP == 0) {
            y2 = 0;
            y1 = height2;
            expandable = false;
        } else {
            y1 = (screenHeight - height1 - height2) / 2;
            y1 = y1 >= 5 ? y1 : 5;
            y2 = y1 + height1;
        }
        return [fontPrimary, fontSecondary, height1, height2, y1, y2, xShift, expandable];
    }

}