/****************************************************************************
**
** Copyright (C) 2013 Digia Plc
** All rights reserved.
** For any questions to Digia, please use contact form at http://qt.digia.com
**
** This file is part of the Qt Virtual Keyboard add-on for Qt Enterprise.
**
** Licensees holding valid Qt Enterprise licenses may use this file in
** accordance with the Qt Enterprise License Agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and Digia.
**
** If you have questions regarding the use of this file, please use
** contact form at http://qt.digia.com
**
****************************************************************************/

import QtQuick 2.0
import QtQuick.Enterprise.VirtualKeyboard 1.1

Item {
    property bool active: listView.currentIndex != -1
    property int highlightIndex: -1
    property alias listView: listView
    property int keyCode
    property point origin
    property bool uppercased: keyboard.uppercased
    signal clicked

    z: 1
    visible: active
    anchors.fill: parent

    ListModel {
        id: listModel
    }

    ListView {
        id: listView
        spacing: 0
        model: listModel
        delegate: keyboard.style.alternateKeysListDelegate
        highlight: keyboard.style.alternateKeysListHighlight ? keyboard.style.alternateKeysListHighlight : defaultHighlight
        highlightMoveDuration: 0
        highlightResizeDuration: 0
        keyNavigationWraps: true
        orientation: ListView.Horizontal
        height: keyboard.style.alternateKeysListItemHeight
        x: origin.x
        y: origin.y - height - keyboard.style.alternateKeysListBottomMargin
        Component {
            id: defaultHighlight
            Item {}
        }
    }

    Loader {
        id: backgroundLoader
        sourceComponent: keyboard.style.alternateKeysListBackground
        anchors.fill: listView
        z: -1
        Binding {
            target: backgroundLoader.item
            property: "currentItemHighlight"
            value: listView.currentIndex === highlightIndex
            when: backgroundLoader.item !== null && listView.currentIndex != -1
        }
    }

    onClicked: {
        if (active) {
            var activeKey = listView.model.get(listView.currentIndex)
            InputContext.inputEngine.virtualKeyClick(keyCode, activeKey.text,
                                                     uppercased ? Qt.ShiftModifier : 0)
        }
    }

    function open(key, originX, originY) {
        keyCode = key.key
        var alternativeKeys = key.alternativeKeys
        if (alternativeKeys.length > 0) {
            for (var i = 0; i < alternativeKeys.length; i++) {
                listModel.append({ "text": uppercased ? alternativeKeys[i].toUpperCase() : alternativeKeys[i] })
            }
            listView.width = keyboard.style.alternateKeysListItemWidth * listModel.count
            listView.forceLayout()
            highlightIndex = alternativeKeys.indexOf(key.text)
            if (highlightIndex === -1) {
                console.log("AlternativeKeys: active key \"" + key.text + "\" not found in alternativeKeys \"" + alternativeKeys + ".\"")
                highlightIndex = 0
            }
            listView.currentIndex = highlightIndex
            var currentItemOffset = (listView.currentIndex + 0.5) * keyboard.style.alternateKeysListItemWidth
            origin = Qt.point(Math.min(Math.max(keyboard.style.alternateKeysListLeftMargin, originX - currentItemOffset), width - listView.width - keyboard.style.alternateKeysListRightMargin), originY)
            if (backgroundLoader.item && backgroundLoader.item.hasOwnProperty("currentItemOffset")) {
                backgroundLoader.item.currentItemOffset = currentItemOffset
            }
        }
        return active
    }

    function move(mouseX) {
        var newIndex = listView.indexAt(Math.max(1, Math.min(listView.width - 1, mapToItem(listView, mouseX, 0).x)), 1)
        if (newIndex !== listView.currentIndex) {
            listView.currentIndex = newIndex
        }
    }

    function close() {
        listModel.clear()
    }
}
