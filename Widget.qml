import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins
import Quickshell

DesktopPluginComponent {
    id: root

    minWidth: 180
    minHeight: 120

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
    property int days: 0
    property int weeks: 0
    property int hours: 0
    property real progress: 0

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

    function anyDayFilterEnabled() {
        return root.countMondays || root.countTuesdays || root.countWednesdays ||
               root.countThursdays || root.countFridays || root.countSaturdays || root.countSundays;
    }

    function countFilteredDays(from, to) {
        let count = 0;

        let current = new Date(from.getFullYear(), from.getMonth(), from.getDate());

        while (current <= to) {
            if (shouldCountDay(current.getDay()))
                count++;

            current.setDate(current.getDate() + 1);
        }

        return count;
    }

    function countFilteredHours(from, to) {
        let totalHours = 0;

        let current = new Date(from);

        while (current < to) {
            let next = new Date(current);
            next.setHours(current.getHours() + 1);

            if (shouldCountDay(current.getDay())) {
                totalHours++;
            }

            current = next;
        }

        return totalHours;
    }

    function countFilteredRange(from, to) {
        if (!anyDayFilterEnabled()) {
            return to - from;
        }

        let total = 0;
        let current = new Date(from);

        while (current < to) {
            let next = new Date(current);
            next.setHours(current.getHours() + 1);

            if (shouldCountDay(current.getDay())) {
                total += (next - current); // add 1 hour in ms
            }

            current = next;
        }

        return total;
    }

    function update() {
        const now = new Date();
        const end = parseDate(root.endDate);
        const start = parseDate(root.startDate);

        if (!end) return;

        // Days and weeks
        if (anyDayFilterEnabled()) {
            root.days = Math.max(0, countFilteredDays(now, end));
            root.weeks = root.days / 7
            root.hours = countFilteredHours(now, end);
        } else {
            const diffMs = end - now;

            root.days = diffMs / (1000 * 60 * 60 * 24);
            root.weeks = root.days / 7;
            root.hours = diffMs / (1000 * 60 * 60);
        }

        // Progress bar
        if (start) {
            let total, elapsed;

            if (anyDayFilterEnabled()) {
                total = countFilteredRange(start, end);
                elapsed = countFilteredRange(start, now);
            } else {
                total = end - start;
                elapsed = now - start;
            }

            root.progress = total > 0
                ? Math.min(1, Math.max(0, elapsed / total))
                : 0;
        } else {
            root.progress = 0;
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
        onDateChanged: root.update()
    }

    Component.onCompleted: update()

    Rectangle {
        anchors.fill: parent
        radius: Theme.cornerRadius
        color: Theme.withAlpha(Theme.surfaceContainer, root.bgOpacity)

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 6

            // Label
            StyledText {
                text: root.label
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Font.Bold
                color: Theme.surfaceText
            }

            // Progress bar (only if start date exists)
            Row {
                visible: root.startDate !== ""
                spacing: 6
                width: parent.width

                Rectangle {
                    height: 6
                    radius: 3
                    width: parent.width - progressText.width - 6
                    color: Theme.surfaceVariant

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
                }
            }

            Column {
                spacing: 2

                StyledText {
                    visible: root.showDays
                    text: root.days.toFixed(1) + " days"
                    color: Theme.surfaceText
                }

                StyledText {
                    visible: root.showWeeks
                    text: root.weeks.toFixed(1) + " weeks"
                    color: Theme.surfaceText
                }

                StyledText {
                    visible: root.showHours
                    text: root.hours + " hours"
                    color: Theme.surfaceText
                }
            }
        }
    }
}