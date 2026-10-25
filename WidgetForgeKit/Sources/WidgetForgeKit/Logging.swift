import os

public enum WFLog {
    public static let subsystem = "com.example.widgetforge"
    public static let store = Logger(subsystem: subsystem, category: "store")
    public static let layout = Logger(subsystem: subsystem, category: "layout")
    public static let widget = Logger(subsystem: subsystem, category: "widget")
    public static let availability = Logger(subsystem: subsystem, category: "availability")
}
