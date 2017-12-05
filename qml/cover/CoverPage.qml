import QtQuick 2.0
import Sailfish.Silica 1.0

import '../lib'

CoverBackground {
    id:mainCoverBackground
    property bool active: status === Cover.Active

    property bool isPlaying: appstate.player.isPlaying
    property bool cassetteAnimationRunning: options.useAnimations && options.useCoverAnimations && active && isPlaying

    property string coverActionCommand:''
    property var externalCommand: appstate.tplayer.externalCommand

    Column {
        id: paddingcontainer
        anchors.fill: parent
        clip: true

        Image {
            id: coverImage
            source: appstate.playlistActive ? appstate.playlistActive.coverImage:''

            anchors.left: parent.left
            anchors.right: parent.right
            height: width

            fillMode: Image.PreserveAspectFit
        }
        Label {
            id: fileNameLabel

            text: appstate.playlistActive ? appstate.playlistActive.baseName : ''

            width: parent.width
            horizontalAlignment: Text.AlignHCenter

            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.primaryColor
            wrapMode: 'WrapAtWordBoundaryOrAnywhere'
        }
        Label {
            id: progressLabel

            text: formatMSeconds( appstate.currentPosition)+" / "+formatMSeconds (appstate.playlistActive ? appstate.playlistActive.duration : 0)

            width: parent.width
            horizontalAlignment: Text.AlignHCenter

            font.pixelSize: Theme.fontSizeTiny
            color: Theme.primaryColor
            wrapMode: 'WrapAtWordBoundaryOrAnywhere'
        }
    }

    ProgressCassette {
        id: coverCassette
        opacity: 0.3
        width: parent.width * 2
        height: width
        x: (-width) / 2
        y: parent.height - (height / 2)

        z: -2

        maximumValue: options.cassetteUseDirectoryDurationProgress ? appstate.playlist.duration: (appstate.playlistIndex > -1 ? appstate.playlist.get(appstate.playlistIndex).duration: 0) //appstate.playlistActive.duration
        value: (appstate.currentPosition || (maximumValue - minimumValue) * 0.01 ) + (options.cassetteUseDirectoryDurationProgress ? appstate.playlist.get(appstate.playlistIndex).playlistOffset :0)
        running: cassetteAnimationRunning
        rotationOffset: -45
    }

//    Column {
//        id: centeredItem

//        anchors.centerIn: parent

//        anchors.bottomMargin: coverCassette.tapeWidth / 3
//        //        height: folderNameLabel.implicitHeight + fileNameLabel.implicitHeight + progressLabel.implicitHeight
//        width: parent.width - Theme.paddingLarge * 2

//        Label {
//            width: parent.width
//            id: fileNameLabel

//            text: appstate.playlistActive ? appstate.playlistActive.baseName : ''

//            horizontalAlignment: Text.AlignHCenter
//            verticalAlignment: Text.AlignVCenter
//            font.pixelSize: Theme.fontSizeExtraSmall
//            color: Theme.primaryColor
//            wrapMode: 'WrapAtWordBoundaryOrAnywhere'
//        }
//        Label {
//            width: parent.width
//            id: progressLabel
//            text: formatMSeconds( appstate.currentPosition)+" / "+formatMSeconds (appstate.playlistActive ? appstate.playlistActive.duration : 0)

//            horizontalAlignment: Text.AlignHCenter
//            verticalAlignment: Text.AlignVCenter
//            font.pixelSize: Theme.fontSizeTiny
//            color: Theme.primaryColor
//            wrapMode: 'WrapAtWordBoundaryOrAnywhere'
//        }
//        Label {
//            width: parent.width
//            id: folderNameLabel3
//            text: appstate.playlistActive && appstate.playlistActive.folderName || ''

//            horizontalAlignment: Text.AlignHCenter
//            verticalAlignment: Text.AlignVCenter
//            font.pixelSize: Theme.fontSizeTiny
//            color: Theme.secondaryColor
//            wrapMode: 'WrapAtWordBoundaryOrAnywhere'
//        }
//    }

    Rectangle {
        anchors.fill: parent
        //color: Theme.highlightBackgroundColor
        gradient: Gradient {
            GradientStop {
                position: 0.6
                color: Qt.rgba(0.0, 0.0, 0.0, 0.0)
            }
            GradientStop {
                position: 0.7
                color: Qt.rgba(0.0, 0.0, 0.0, 0.3)
                //color: Theme.rgba(Theme.highlightColor, 0.2)
            }
            GradientStop {
                position: 1.0
                //color: Theme.rgba(Theme.highlightColor, 0.5)
                color: Qt.rgba(0.0,0.0,0.0, 0.8)
            }
        }
    }

    CoverActionList {
        id: coverActionPrev
        enabled: options.secondaryCoverAction === 'prev'

        CoverAction {
            iconSource: "image://theme/icon-cover-previous-song"

            onTriggered: externalCommand.prev()
        }

        CoverAction {
            iconSource:isPlaying ? "image://theme/icon-cover-pause" : "image://theme/icon-cover-play"

            onTriggered: externalCommand.playPause()
        }
    }

    CoverActionList {
        id: coverActionNext
        enabled: options.secondaryCoverAction === 'next'

        CoverAction {
            iconSource:isPlaying ? "image://theme/icon-cover-pause" : "image://theme/icon-cover-play"

            onTriggered: externalCommand.playPause()
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-next-song"

            onTriggered: externalCommand.next()
        }
    }

    CoverActionList {
        id: coverAction
        enabled: options.secondaryCoverAction === ''

        CoverAction {
            iconSource:isPlaying ? "image://theme/icon-m-previous" : "image://theme/icon-cover-play"

            onTriggered: externalCommand.playPause()
        }
    }
}
