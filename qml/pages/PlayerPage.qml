

/*
TODO:
    - make options page awesome
        - use indexer and directorychooserdialog
        - move 'skip to file' to FirstPage pulley menu
        - sub page for timer
            - disable screen blank option
        - sub page for playback
            - pause between tracks
            - playbackspeed
            - skip ranges
            - show total progress
        - clear all settings
    - cover image
        - fallback?
    - app cover
        - durations, positions, basenames, cover image



*/
import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0
//import QtSystemInfo 5.0


import '../lib'

Page {
    id: page

    allowedOrientations: Orientation.All

    function formatMSeconds (duration, debug) {
        var dur = duration / 1000,
                hours =  Math.floor(dur /3600),
                minutes =  Math.floor((dur - hours * 3600) / 60),
                seconds = Math.floor(dur - (hours * 3600) - minutes * 60);
        if(debug) {
            console.log('formatting duration', duration);
            console.log(dur);
            console.log(hours + 'h');
            console.log(minutes, ' -> ', ("0"+minutes).slice(-2));
            console.log(seconds, ' -> ', ("0"+seconds).slice(-2));
        }
        return (hours?(hours+':'):'')+ ("0"+minutes).slice(-2) + ':' + ("0"+seconds).slice(-2);
        //return;
    }

    property Audio playback: appstate.player
    property int directoryDuration : appstate.playlistDuration
    property bool isplaying: false //should i be playing? (regardless of actual playback state)
    property bool isPlaying: playback.isPlaying

    onDirectoryDurationChanged: {
        page.readDurations();
    }


    function readDurations (){
        //        return;
        var l = appstate.playlist.count,
                i = 0,
                currentIndex = -1,
                previousDuration = 0,
                totalDuration = 0;
        log('readdurations', l);
        //page.fileCount = l;
        while(i<l){
            if('file://'+appstate.playlist.get(i).path === playback.source.toString()){
                currentIndex = i;
                //console.log('currentIndex', i);
            }
            if(currentIndex === -1) {
                previousDuration = previousDuration + appstate.playlist.get(i).duration;
            }
            totalDuration = totalDuration + appstate.playlist.get(i).duration;

            i++;
        }

        totalPosition.previousDuration = previousDuration;
    }



    SilicaFlickable {
        anchors.fill: parent
        id: mainFlickable
        PullDownMenu {
            id: pulleyTop
            OpenPlaylistButton {
                id: opnBtn
                visible: false
            }

            OpenPlaylistButton {
                id: enqueueBtn
                visible: false
                enqueue: true
            }

            MenuItem {
                text: qsTr('Options', 'pulley')
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("OptionsPage.qml"), {options:options,appstate:appstate, firstPage:page, log: log});
                }
            }
            MenuItem {
                //                enabled: options.directoryDuration !== playback.duration
                visible: appstate.playlist.count > 0
                text: qsTr('Playlist', 'pulley')
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("PlaylistPage.qml"), {options:options,appstate:appstate, firstPage:page, log: log});
                }
            }

            MenuItem {
                text: qsTr("Enqueue", 'pulley')
                visible: appstate.playlist.count > 0 && options.showEnqueuePulley
                onClicked:
                    enqueueBtn.openDirectoryDialog() //pageStack.push(Qt.resolvedUrl("SecondPage.qml"))
            }
            MenuItem {
                text: qsTr("Open", 'pulley')
                onClicked:
                    opnBtn.openDirectoryDialog() //pageStack.push(Qt.resolvedUrl("SecondPage.qml"))
            }

        }

        Flow {
            anchors.fill: parent
            anchors.topMargin: Theme.paddingSmall

            Image {
                id: coverImage
                source: appstate.playlistActive && appstate.playlistIndex > -1 ? appstate.playlistActive.coverImage:''

                width: parent.width
                height: width

                fillMode: Image.PreserveAspectFit
            }

            Column {
                width: parent.width

                Label {
                    width: parent.width - Theme.paddingSmall * 2
                    id: fileNameLabel
                    text: appstate.playlistActive ? appstate.playlistActive.baseName :''

                    horizontalAlignment: Text.AlignHCenter

                    color: Theme.highlightColor
                    wrapMode: 'WrapAtWordBoundaryOrAnywhere'
                }

                Label {
                    width: parent.width - Theme.paddingSmall * 2
                    id: fileFolderLabel
                    property string displayPath:appstate.playlistActive && appstate.playlistActive.folderName ? appstate.playlistActive.folderName:''
                    visible: displayPath !== '' && options.playerDisplayDirectoryName

                    text: displayPath
                    horizontalAlignment: Text.AlignHCenter

                    color: Theme.secondaryHighlightColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    wrapMode: 'WrapAtWordBoundaryOrAnywhere'
                }

                Slider {
                    id: currentPositionSlider
                    value: Math.max( realvalue, appstate.currentPosition)
                    property real realvalue: playback.position
                    onRealvalueChanged: {

                        value = Math.max( realvalue, appstate.currentPosition)
                    }

                    minimumValue: 0
                    maximumValue: appstate.playlistActive && appstate.playlistActive.duration > 0? appstate.playlistActive.duration:0.0001
                    width: parent.width
                    height: Theme.itemSizeExtraSmall
                    visible: appstate.playlistIndex != -1
                    label: formatMSeconds( value)+" / "+formatMSeconds(maximumValue) +' ('+ (Math.floor(( currentPositionSlider.value / currentPositionSlider.maximumValue) * 1000 ) / 10)+'%)'
                    //Rectangle { anchors.fill: parent; color: "red"; opacity: 0.3; z:-1;}

                    onPressedChanged: {
                        if (!pressed) {
                            //                            if(sleepTimer.running) {sleepTimer.restart();}
                            if(value + 100 >= appstate.playlistActive.duration){//does not quite set it at the end, so skipping gets confused.
                                value = appstate.playlistActive.duration - 100;
                            }
                            appstate.currentPosition = value;
                            //also does not update state?!
                            playback.seek(value);
                            value = Math.max( realvalue, appstate.currentPosition)
                        }
                    }
                }


                Slider {
                    id: totalPosition
                    property int previousDuration: appstate.playlistActive.playlistOffset
                    value: (appstate.playlistActive ? appstate.playlistActive.playlistOffset:0) + currentPositionSlider.value
                    visible: options.playerDisplayDirectoryProgress && appstate.playlistIndex > -1 && appstate.playlist.count > 1// options.directoryFiles && options.directoryFiles.length > 1// && appstate.playlistIndex !== -1
                    opacity: 0.5
                    minimumValue: 0
                    height: Theme.itemSizeExtraSmall
                    Label {
                        color: Theme.secondaryColor
                        width: parent.width
                        height: Theme.itemSizeSmall
                        opacity: 0.8
                        horizontalAlignment: Text.AlignHCenter
                        anchors.bottom: parent.bottom
                        verticalAlignment: Text.AlignBottom
                        font.pixelSize: Theme.fontSizeExtraSmall
                        visible: appstate.playlistIndex > -1 && appstate.playlist.count > 1
                        text:  qsTr('%1 / %2 (File %L3 of %L4)', 'formatted file/directory durations, then file number/count )').arg(formatMSeconds( totalPosition.value)).arg(formatMSeconds(totalPosition.maximumValue)).arg(appstate.playlistIndex+1).arg(appstate.playlist.count)
                    }
                    maximumValue: appstate.playlist.duration
                    enabled: false
                    width: parent.width
                    handleVisible: false


                    MouseArea {
                        anchors.fill: totalPosition
                        onClicked: {

                            totalDurationNotification.show(2000)
                        }

                        InlineNotification {
                            id: totalDurationNotification
                            //isvisible: true
                            anchors.centerIn: parent
                            height:isvisible ? parent.height : 0
                            width: totalPosition.width
                            property int totalperc: totalPosition.maximumValue ? (Math.floor(( totalPosition.value / totalPosition.maximumValue) * 1000 ) / 10) : 0
                            text: qsTr('%1% played in Total', 'directory progress', totalperc).arg(totalperc)
                        }
                    }
                }
            }
        }

        //control panel

        Item {
            id: controlPanel
            // visibleSize: Theme.itemSizeLarge
            width: page.isPortrait ? parent.width : Theme.itemSizeLarge + Theme.paddingLarge
            height: page.isPortrait ? Theme.itemSizeLarge + Theme.paddingLarge : parent.height
            anchors.bottom: parent.bottom
            anchors.right: parent.right

            Flow {
                height: page.isLandscape ? sizeOfEntries : Theme.itemSizeLarge
                width: page.isPortrait ? sizeOfEntries : Theme.itemSizeLarge
                anchors.centerIn: parent
                spacing: 20
                id:iconButtons


                property int numberOfEntries: 5 //todo: make model/repeater with json
                property int sizeOfEntries: (Theme.itemSizeSmall + spacing) * numberOfEntries - spacing;

                property bool isPlaying: appstate.tplayer.isplaying

                IconButton {
                    icon.source: "../icon-l-frwd.png"
                    enabled: totalPosition.value > options.skipDurationNormal
                    onClicked: {
                        appstate.tplayer.seek(0 - options.skipDurationNormal)
                    }
                }
                IconButton {
                    enabled: totalPosition.value > options.skipDurationSmall
                    icon.source: "../icon-l-rwd.png"
                    onClicked: {
                        appstate.tplayer.seek(0 - options.skipDurationSmall)
                    }
                }
                IconButton {
                    id: play
                    enabled: appstate.playlistIndex > -1 && appstate.playlist.count > 0
                    icon.source: playback.playbackState == Audio.PlayingState ? "image://theme/icon-l-pause": "image://theme/icon-l-play"
                    onClicked: appstate.tplayer.playPause()
                }
                IconButton {
                    icon.source: "../icon-l-fwd.png"
                    enabled: totalPosition.maximumValue - totalPosition.value > options.skipDurationSmall
                    onClicked: {
                        appstate.tplayer.seek(options.skipDurationSmall)
                    }
                }
                IconButton {
                    icon.source: "../icon-l-ffwd.png"
                    enabled: totalPosition.maximumValue - totalPosition.value > options.skipDurationNormal
                    onClicked: {
                        appstate.tplayer.seek( options.skipDurationNormal)
                    }
                }
            }
        }
    }
}
