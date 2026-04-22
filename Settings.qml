import QtQuick
import qs.Common
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "dmsDesktopCountdown"

    // General info
    StringSetting {
        settingKey: "label"
        label: "Label"
        description: "The label to display for this countdown"
        placeholder: "Label"
        defaultValue: "Countdown"
    }

    StringSetting {
        settingKey: "startDate"
        label: "Start Date"
        description: "The start date and time to count from. Can be left empty (YYYY-MM-DD hh:mm:ss)"
        placeholder: "Start date"
        defaultValue: ""
    }

    StringSetting {
        settingKey: "endDate"
        label: "End Date"
        description: "The end date and time to count to (YYYY-MM-DD hh:mm:ss)"
        placeholder: "End date"
        defaultValue: "2027-01-01"
    }
    
    // View options
    ToggleSetting {
        settingKey: "showHours"
        label: "Show hours"
        description: "Show the number of hours until the end date"
        defaultValue: false
    }

    ToggleSetting {
        settingKey: "showDays"
        label: "Show days"
        description: "Show the number of days until the end date"
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "showWeeks"
        label: "Show weeks"
        description: "Show the number of weeks until the end date"
        defaultValue: false
    }

    // Count options
    ToggleSetting {
        settingKey: "countMondays"
        label: "Count Mondays"
        description: "Count Mondays until the end date"
        defaultValue: false
    }

    ToggleSetting {
        settingKey: "countTuesdays"
        label: "Count Tuesdays"
        description: "Count Tuesdays until the end date"
        defaultValue: false
    }

    ToggleSetting {
        settingKey: "countWednesdays"
        label: "Count Wednesdays"
        description: "Count Wednesdays until the end date"
        defaultValue: false
    }

    ToggleSetting {
        settingKey: "countThursdays"
        label: "Count Thursdays"
        description: "Count Thursdays until the end date"
        defaultValue: false
    }

    ToggleSetting {
        settingKey: "countFridays"
        label: "Count Fridays"
        description: "Count Fridays until the end date"
        defaultValue: false
    }

    ToggleSetting {
        settingKey: "countSaturdays"
        label: "Count Saturdays"
        description: "Count Saturdays until the end date"
        defaultValue: false
    }

    ToggleSetting {
        settingKey: "countSundays"
        label: "Count Sundays"
        description: "Count Sundays until the end date"
        defaultValue: false
    }

    // Opacity
    SliderSetting {
        settingKey: "backgroundOpacity"
        label: "Background Opacity"
        defaultValue: 80
        minimum: 0
        maximum: 100
        unit: "%"
    }
}