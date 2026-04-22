import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins
import qs.Services
import Quickshell

DesktopPluginComponent {
    id: root

    minWidth: 200
    minHeight: 140

    property bool initalized: false

    property string label: pluginData.label ?? "Countdown"
    property string startDate: pluginData.startDate ?? ""
    property string endDate: pluginData.endDate ?? ""

    property bool showHours: pluginData.showHours ?? false
    property bool showDays: pluginData.showDays ?? true
    property bool showWeeks: pluginData.showWeeks ?? false

    property bool countMondays: pluginData.countMondays ?? false
    property bool countTuesdays: pluginData.countTuesdays ?? false
    property bool countWednesdays: pluginData.countWednesdays ?? false
    property bool countThursdays: pluginData.countThursdays ?? false
    property bool countFridays: pluginData.countFridays ?? false
    property bool countSaturdays: pluginData.countSaturdays ?? false
    property bool countSundays: pluginData.countSundays ?? false

    property real bgOpacity: (pluginData.backgroundOpacity ?? 80) / 100

    // Computed values
    property real days: 0
    property real weeks: 0
    property real hours: 0
    property real progress: 0

    property bool invalidEndDate: false
    property bool invalidStartDate: false

    /*
    Parses a date string in the format "YYYY-MM-DD HH:mm:ss"

    Parameters:
        str: The date string to parse

    Returns:
        The parsed Date object, or null if the string is invalid
    */
    function parseDate(str) {
        if (!str) return null;

        const parts = str.split(" ");
        const dateParts = parts[0].split("-");

        if (dateParts.length !== 3) return null;

        const y = parseInt(dateParts[0]);
        const m = parseInt(dateParts[1]) - 1;
        const d = parseInt(dateParts[2]);

        let h = 0, min = 0, s = 0;

        if (parts.length > 1) {
            const timeParts = parts[1].split(":");
            h = parseInt(timeParts[0]) || 0;
            min = parseInt(timeParts[1]) || 0;
            s = parseInt(timeParts[2]) || 0;
        }

        return new Date(y, m, d, h, min, s);
    }

    /*
    Checks if a day should be counted based on the enabled days to count

    Parameters:
        day: The day to check (0-6)

    Returns:
        True if the day should be counted, false otherwise
    */
    function shouldCountDay(day) {
        return (
            (day === 1 && root.countMondays) ||
            (day === 2 && root.countTuesdays) ||
            (day === 3 && root.countWednesdays) ||
            (day === 4 && root.countThursdays) ||
            (day === 5 && root.countFridays) ||
            (day === 6 && root.countSaturdays) ||
            (day === 0 && root.countSundays)
        );
    }

    /*
    Checks if any day filter is enabled

    Returns:
        True if any day filter is enabled, false otherwise
    */
    function anyDayFilterEnabled() {
        return root.countMondays || root.countTuesdays || root.countWednesdays ||
               root.countThursdays || root.countFridays || root.countSaturdays || root.countSundays;
    }

    /*
    Formats a date in a human-readable format

    Parameters:
        date: The date string to format

    Returns:
        The formatted date
    */
    function prettyDate(string) {
        const date = parseDate(string);

        return date.toLocaleDateString("en-US", {
            day: "numeric",
            month: "long",
            year: "numeric",
            hour: "numeric",
            minute: "numeric",
            second: "numeric"
        });
    }

    /*
    Counts the number of milliseconds between two dates. If any day filter is enabled, only hours that match the filter will be counted

    Parameters:
        from: The start date
        to: The end date

    Returns:
        The number of milliseconds
    */
    function countFilteredMs(from, to) {
        if (!anyDayFilterEnabled()) {
            return to - from;
        }

        let total = 0;

        let current = new Date(from.getFullYear(), from.getMonth(), from.getDate());
        const endDay = new Date(to.getFullYear(), to.getMonth(), to.getDate());

        while (current <= endDay) {
            if (shouldCountDay(current.getDay())) {
                // start of this day
                let dayStart = new Date(current);
                let dayEnd = new Date(current);
                dayEnd.setHours(23, 59, 59, 999);

                // clamp to range
                if (dayStart < from) dayStart = from;
                if (dayEnd > to) dayEnd = to;

                if (dayEnd > dayStart) {
                    total += (dayEnd - dayStart);
                }
            }

            current.setDate(current.getDate() + 1);
        }

        return total;
    }

    /*
    Updates the values for the widget
    */
    function update() {
        const now = new Date();
        const end = parseDate(root.endDate);
        const start = parseDate(root.startDate);

        if (root.initalized && end === null) {
            root.invalidEndDate = true;
            ToastService.showError("Invalid countdown end date", "The provided end date for countdown '" + root.label + "' is invalid.");
            return;
        } else {
            root.invalidEndDate = false;
        }

        if (root.initalized && (start === null || start > end) && root.startDate !== "") {
            root.invalidStartDate = true;
            ToastService.showError("Invalid countdown start date", "The provided start date for countdown '" + root.label + "' is invalid.");
            return;
        } else {
            root.invalidStartDate = false;
        }

        const filteredMs = countFilteredMs(now, end);

        root.hours = Math.max(0, filteredMs / (1000 * 60 * 60));
        root.days  = root.hours / 24;
        root.weeks = root.days / 7;

        // Progress
        if (start) {
            const total = countFilteredMs(start, end);
            const elapsed = countFilteredMs(start, now);

            root.progress = total > 0
                ? Math.min(1, Math.max(0, elapsed / total))
                : 0;
        } else {
            root.progress = 0;
        }
    }

    // Update the values once the widget is loaded
    Timer {
        interval: 0
        running: true
        repeat: false
        onTriggered: {
            initalized = true
            root.update()
        }
    }

    // Then, update the values every minute
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
        onDateChanged: root.update()
    }

    // Update the values when settings change
    onLabelChanged: update()
    onStartDateChanged: update()
    onEndDateChanged: update()
    onShowHoursChanged: update()
    onShowDaysChanged: update()
    onShowWeeksChanged: update()
    onCountMondaysChanged: update()
    onCountTuesdaysChanged: update()
    onCountWednesdaysChanged: update()
    onCountThursdaysChanged: update()
    onCountFridaysChanged: update()
    onCountSaturdaysChanged: update()
    onCountSundaysChanged: update()

    Rectangle {
        anchors.fill: parent
        radius: Theme.cornerRadius
        color: Theme.withAlpha(Theme.surfaceContainer, root.bgOpacity)

        Column {
            anchors.fill: parent
            anchors.margins: 10

            StyledText {
                text: "Invalid end date"
                color: Theme.error
                visible: root.invalidEndDate
            }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 6
            visible: !root.invalidEndDate

            // Label
            StyledText {
                text: root.label
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Font.Bold
                color: Theme.surfaceText
            }

            // Dates
            Row {
                spacing: 4
                width: parent.width

                DankIcon {
                    name: "calendar_today"
                    size: Theme.iconSize / 2
                    opacity: 0.5
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    text: prettyDate(root.ssurfaceTexttartDate) + " -"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceText
                    opacity: 0.5
                    visible: root.startDate !== ""
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    text: prettyDate(root.endDate)
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceText
                    opacity: 0.5
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Progress bar (only if start date exists)
            Row {
                visible: root.startDate !== "" && !root.invalidStartDate
                spacing: 6
                width: parent.width

                Rectangle {
                    height: 6
                    radius: 3
                    width: parent.width - progressText.width - 6
                    color: Theme.surfaceVariant
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        height: parent.height
                        width: parent.width * Math.max(0, Math.min(1, root.progress))
                        radius: 3
                        color: Theme.primary
                    }
                }

                StyledText {
                    id: progressText
                    text: (root.progress * 100).toFixed(2) + "%"
                    color: Theme.surfaceText
                    font.pixelSize: Theme.fontSizeSmall
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Column {
                width: parent.width
                spacing: 2


                Row {
                    spacing: 4
                    width: parent.width
                    visible: root.showHours

                    DankIcon {
                        name: "access_time"
                        size: Theme.iconSize / 2
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        text: root.hours.toFixed(1) + " hours"
                        color: Theme.surfaceText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    spacing: 4
                    width: parent.width
                    visible: root.showDays

                    DankIcon {
                        name: "calendar_view_day"
                        size: Theme.iconSize / 2
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        text: root.days.toFixed(1) + " days"
                        color: Theme.surfaceText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                Row {
                    spacing: 4
                    width: parent.width
                    visible: root.showWeeks

                    DankIcon {
                        name: "calendar_view_week"
                        size: Theme.iconSize / 2
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        text: root.weeks.toFixed(1) + " weeks"
                        color: Theme.surfaceText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            StyledText {
                text: "Invalid start date"
                color: Theme.error
                visible: root.invalidStartDate
            }
        }
    }
}