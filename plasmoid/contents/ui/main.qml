import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as P5Support

PlasmoidItem {
    id: root

    property string batteryText: "🔋 --"

    // Path to our bundled scripts
    property string scriptsDir: Qt.resolvedUrl("../scripts")

    // Command to read the battery status file
    property string batteryCmd: "cat /tmp/remote_battery_status 2>/dev/null || echo ''"

    // Start the receiver daemon on widget load
    P5Support.DataSource {
        id: receiverStarter
        engine: "executable"
        connectedSources: []
        
        onNewData: function(sourceName, data) {
            // Receiver started or already running; disconnect
            disconnectSource(sourceName);
        }
    }

    // Read battery data periodically
    P5Support.DataSource {
        id: batterySource
        engine: "executable"
        connectedSources: [batteryCmd]
        interval: 3000

        onNewData: function(sourceName, data) {
            var stdout = (data["stdout"] || "").trim();
            if (stdout.length > 0) {
                var parts = stdout.split(",");
                if (parts.length === 2) {
                    var status = parts[0].trim();
                    var pct = parts[1].trim();
                    var icon = status === "Charging" ? "⚡" : "🔋";
                    root.batteryText = icon + " " + pct + "%";
                } else {
                    root.batteryText = "🔋 ??";
                }
            } else {
                root.batteryText = "🔋 --";
            }
        }
    }

    // Launch receiver at startup
    Component.onCompleted: {
        var startCmd = "bash " + scriptsDir.toString().replace("file://", "") + "/start_receiver.sh";
        receiverStarter.connectSource(startCmd);
    }

    preferredRepresentation: compactRepresentation

    compactRepresentation: PlasmaComponents.Label {
        text: root.batteryText
        font.pixelSize: Kirigami.Units.gridUnit * 0.8
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        Layout.minimumWidth: Kirigami.Units.gridUnit * 3
        Layout.minimumHeight: Kirigami.Units.gridUnit * 1.5
    }

    fullRepresentation: PlasmaComponents.Label {
        text: root.batteryText
        font.pixelSize: Kirigami.Units.gridUnit * 1.5
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        Layout.preferredWidth: Kirigami.Units.gridUnit * 10
        Layout.preferredHeight: Kirigami.Units.gridUnit * 5
    }
}
