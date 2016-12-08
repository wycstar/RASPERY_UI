import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.0

ApplicationWindow{
    id:main
    x:0
    y:0
    width:800;
    height:480;
    color: "#ff333333";
    visible:true;
    flags:Qt.FramelessWindowHint | Qt.WA_TranslucentBackground;
    property string mainColor: "#5fb2ff"
    property var powerWindowObject
    property var pyRoot
    property bool isAllGraphStarted:false
    property bool isGraphPause:false
    property bool isHyGraphSubWindowExist:false
    property int captionHeight: 50
    property double fontScale: 1.6
    property double autoScale: 0.57
    property double smallAutoScale: 0.8
    property double offSetY: (1 - autoScale) * hyPowerDock.height / 2
    property double liCapacity: 2 * 16000 * 31.6 / 1000 / 1000 //mah * 平均耗电电压,两块电池
    property double hyCapacity: 9 * (30.0 / 0.1) / 700 //700L出1KWH的电
    property double wholeEnergy: liCapacity + hyCapacity
    property double currentEnergy: wholeEnergy

    signal closeApplication()

    //氢气剩余仪表
    Image{
        id:hyRemainDock
        x:200 * (smallAutoScale - 1) / 2;
        y:hyPowerDock.height * 0.8 - height + captionHeight + 15 - offSetY;
        width:200
        height: 200
        scale: smallAutoScale
        source: "resource/pic/hyremain.png"
        Text{
            id:hyRemainCaption
            x:(hyRemainDock.width - width) / 2
            y:-40
            color:"white"
            text:"氢气剩余"
            font.family: "文泉驿"
            font.bold: false
            font.pointSize: 16
        }
        Image{
            id:hyRemainGraphIcon
            source: "resource/pic/gas.png"
            x:hyRemainDock.width / 2 - width / 2
            y:hyRemainIncicator.y + hyRemainIncicator.height + 10
            height:40
            width: 40
        }
        Text{
            id:hyRemainIncicator
            x:hyRemainDock.width / 2 - width / 2
            y:120
            color:"white"
            text:"0MPa"
            font.family: lcdFont.name
            font.bold: true
            font.pointSize: 10 * fontScale
        }
        Rectangle{
            id:hyRemainPointerWrapper
            width:hyRemainDock.width
            height:hyRemainDock.height
            color:Qt.rgba(0, 0, 0, 0)
            property int pointerAngle: -30
            Canvas{
                id:hyRemainPointer
                width:hyRemainDock.width
                height:hyRemainDock.height
                property int pointerRadius: 4
                property int pointerStart: 20
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.save();
                    ctx.clearRect(0, 0, hyRemainDock.width, hyRemainDock.height);
                    ctx.beginPath();
                    ctx.lineWidth = 1;
                    ctx.strokeStyle = main.mainColor;
                    ctx.fillStyle = main.mainColor;
                    ctx.moveTo(hyRemainPointer.pointerStart, hyRemainDock.height / 2);
                    ctx.lineTo(hyRemainDock.width / 2, hyRemainDock.height / 2 - hyRemainPointer.pointerRadius);
                    ctx.arc(hyRemainDock.width / 2,
                            hyRemainDock.height / 2,
                            hyRemainPointer.pointerRadius,
                            -Math.PI / 2,
                            Math.PI / 2);
                    ctx.lineTo(hyRemainPointer.pointerStart, hyRemainDock.height / 2);
                    ctx.closePath()
                    ctx.fill()
                    ctx.stroke();}
            }
            transform: Rotation{origin.x: hyRemainPointerWrapper.width / 2;
                                origin.y: hyRemainPointerWrapper.height / 2;
                                angle: hyRemainPointerWrapper.pointerAngle}
        }
    }
    //氢气仪表
    Image{
        id:hyPowerDock
        x:hyRemainDock.width * 0.9 * (3 * autoScale - 1) / 2 - hyRemainDock.width * (1 - hyRemainDock.scale) / 2 + hyRemainDock.x;
        y: captionHeight - offSetY;
        width:500
        height: 500
        scale: autoScale
        source: "resource/pic/hy.png"
        Text{
            id:hyPowerCaption
            x:(hyPowerDock.width - width) / 2
            y:-50
            color:"white"
            text:"燃料电池功率"
            font.family: "文泉驿"
            font.bold: false
            font.pointSize: 22
        }
        Image{
            id:hyPowerGraphIcon
            source: "resource/pic/wave.png"
            x:hyPowerDock.width / 2 - width / 2
            y:hyPowerIncicator.y + hyPowerIncicator.height + 30
            height:60
            width: 120
            MouseArea{
                anchors.fill: parent
                onClicked: {var component = Qt.createComponent("/home/wyc/code/ui/powerGraph.qml");
                            if(component.status == Component.Ready){
								isHyGraphSubWindowExist = true
                                powerWindowObject = component.createObject()
                                powerWindowObject.visible = true
                                powerWindowObject.pauseGraph.connect(pauseGraph)
                                powerWindowObject.clearGraph.connect(clearGraph)
                                isAllGraphStarted = true
								powerWindowObject.main = main
								main.hide()
								powerWindowObject.raise()}}
            }
        }
        Text{
            id:hyPowerIncicator
            x:hyPowerDock.width / 2 - width / 2
            y:330
            color:"white"
            text:"0W"
            font.family: lcdFont.name
            font.bold: true
            font.pointSize: 20 * fontScale
        }
        Rectangle{
            id:hyPowerPointerWrapper
            width:500
            height:500
            color:Qt.rgba(0, 0, 0, 0)
            property int pointerAngle: -30
            Canvas{
                id:hyPowerPointer
                width:500
                height:500
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.save();
                    ctx.clearRect(0, 0, hyPowerDock.width, hyPowerDock.height);
                    ctx.beginPath();
                    ctx.lineWidth = 1;
                    ctx.strokeStyle = main.mainColor;
                    ctx.fillStyle = main.mainColor;
                    ctx.moveTo(50, hyPowerDock.height / 2);
                    ctx.lineTo(hyPowerDock.width / 2, hyPowerDock.height / 2 - 10);
                    ctx.arc(hyPowerDock.width / 2,
                            hyPowerDock.height / 2,
                            10,
                            -Math.PI / 2,
                            Math.PI / 2);
                    ctx.lineTo(50, hyPowerDock.height / 2);
                    ctx.closePath()
                    ctx.fill()
                    ctx.stroke();}
            }
            transform: Rotation{origin.x: hyPowerPointerWrapper.width / 2;
                                origin.y: hyPowerPointerWrapper.height / 2;
                                angle: hyPowerPointerWrapper.pointerAngle}
        }
    }
    //锂电池仪表
    Image{
        id:liPowerDock
        x:hyPowerDock.x + width * 0.9 * autoScale;
        y:captionHeight - offSetY;
        width:500
        height: 500
        scale: autoScale
        source: "resource/pic/li.png"
        Text{
            id:liPowerCaption
            x:(liPowerDock.width - width) / 2
            y:-50
            color:"white"
            text:"锂电池功率"
            font.family: "文泉驿"
            font.bold: false
            font.pointSize: 22
        }
        Image{
            id:liPowerGrapthIcon
            source: "resource/pic/wave.png"
            x:liPowerDock.width / 2 - width / 2
            y:liPowerIncicator.y + liPowerIncicator.height + 30
            height:60
            width: 120
        }
        Text{
            id:liPowerIncicator
            x:liPowerDock.width / 2 - width / 2
            y:330
            color:"white"
            text:"0W"
            font.family: lcdFont.name
            font.bold: true
            font.pointSize: 20 * fontScale
        }
        Rectangle{
            id:liPowerPointerWrapper
            width:500
            height:500
            color:Qt.rgba(0, 0, 0, 0)
            property int pointerAngle: -30
            Canvas{
                id:liPowerPointer
                width:500
                height:500
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.save();
                    ctx.clearRect(0, 0, liPowerDock.width, liPowerDock.height);
                    ctx.beginPath();
                    ctx.lineWidth = 1;
                    ctx.strokeStyle = main.mainColor;
                    ctx.fillStyle = main.mainColor;
                    ctx.moveTo(50, liPowerDock.height / 2);
                    ctx.lineTo(liPowerDock.width / 2, liPowerDock.height / 2 - 10);
                    ctx.arc(liPowerDock.width / 2,
                            liPowerDock.height / 2,
                            10,
                            -Math.PI / 2,
                            Math.PI / 2);
                    ctx.lineTo(50, liPowerDock.height / 2);
                    ctx.closePath()
                    ctx.fill()
                    ctx.stroke();}
            }
            transform: Rotation{origin.x: liPowerPointerWrapper.width / 2;
                                origin.y: liPowerPointerWrapper.height / 2;
                                angle: liPowerPointerWrapper.pointerAngle}
        }
    }
    //锂电池剩余仪表
    Image{
        id:liRemainDock
        x:main.width - width * (smallAutoScale + 1) / 2;
        y:hyRemainDock.y;
        z:-1
        width:200
        height: 200
        scale: smallAutoScale
        source: "resource/pic/liremain.png"
        Text{
            id:liRemainCaption
            x:(liRemainDock.width - width) / 2
            y:-40
            color:"white"
            text:"锂电池剩余"
            font.family: "文泉驿"
            font.bold: false
            font.pointSize: 16
        }
        Image{
            id:liRemainGraphIcon
            source: "resource/pic/battery.png"
            x:liRemainDock.width / 2 - width / 2
            y:liRemainIncicator.y + liRemainIncicator.height + 10
            height:40
            width: 20
        }
        Text{
            id:liRemainIncicator
            x:liRemainDock.width / 2 - width / 2
            y:120
            color:"white"
            text:String(0) + "V"
            font.family: lcdFont.name
            font.bold: true
            font.pointSize: 10 * fontScale
        }
        Rectangle{
            id:liRemainPointerWrapper
            width:liRemainDock.width
            height:liRemainDock.height
            color:Qt.rgba(0, 0, 0, 0)
            property int pointerAngle: -30
            Canvas{
                id:liRemainPointer
                width:liRemainDock.width
                height:liRemainDock.height
                property int pointerRadius: 4
                property int pointerStart: 20
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.save();
                    ctx.clearRect(0, 0, liRemainDock.width, liRemainDock.height);
                    ctx.beginPath();
                    ctx.lineWidth = 1;
                    ctx.strokeStyle = main.mainColor;
                    ctx.fillStyle = main.mainColor;
                    ctx.moveTo(liRemainPointer.pointerStart, liRemainDock.height / 2);
                    ctx.lineTo(liRemainDock.width / 2, liRemainDock.height / 2 - liRemainPointer.pointerRadius);
                    ctx.arc(liRemainDock.width / 2,
                            liRemainDock.height / 2,
                            liRemainPointer.pointerRadius,
                            -Math.PI / 2,
                            Math.PI / 2);
                    ctx.lineTo(liRemainPointer.pointerStart, liRemainDock.height / 2);
                    ctx.closePath()
                    ctx.fill()
                    ctx.stroke();}
            }
            transform: Rotation{origin.x: liRemainPointerWrapper.width / 2;
                                origin.y: liRemainPointerWrapper.height / 2;
                                angle: liRemainPointerWrapper.pointerAngle}
        }
    }
    Rectangle{
        id: timeRemainDock
        x:100
        y:380
        width: main.width - 2 * x
        height: 50
        color: main.color
        Canvas{
            id: timeRemainCanvas
            width: timeRemainDock.width
            height: timeRemainDock.height

            property var percent: 100
            property color primaryColor: "#0883bb"
            property color secondaryColor: "orange"

            onPercentChanged: requestPaint()

            onPaint: {
                var ctx = getContext("2d");
                ctx.save();
                ctx.clearRect(0, 0, timeRemainCanvas.width, timeRemainCanvas.height);

                //绘制剩余百分比
                ctx.beginPath();
                ctx.lineWidth = timeRemainDock.height - 10;
                ctx.strokeStyle = secondaryColor;
                ctx.moveTo(0, 0)
                ctx.lineTo(timeRemainCanvas.width * (100 - percent) / 100, 0)
                ctx.stroke();

                ctx.beginPath();
                ctx.lineWidth = timeRemainDock.height - 10;
                ctx.strokeStyle = primaryColor;
                ctx.moveTo(timeRemainCanvas.width, 0)
                ctx.lineTo(timeRemainCanvas.width * (100 - percent) / 100, 0)
                ctx.stroke();
                ctx.restore();}

            Text{
                id:allPercentText
                x: (timeRemainCanvas.width - width) / 2
                color:"white"
                text:timeRemainCanvas.percent + "%"
                font.family: lcdFont.name
                font.bold: false
                font.pointSize: 18
            }
			Text{
                id:timeRemainCanvasCaption
                x: (timeRemainCanvas.width - width) / 2
				y:-30
                color:"white"
                text:"剩余能量"
                font.family: "文泉驿"
                font.bold: false
                font.pointSize: 16
            }
        }
        Rectangle{
            x: 60

            Rectangle{
                id:timeRemainTextLeftWrap
                x:0
                y:timeRemainDock.height - 10
                Image {
                    id: timeRemainTextLeftPic
                    source: "resource/pic/timeRemain.png"
                    width: 32
                    height:32
                }
                Text{
                    id:remainTimeText
                    x:timeRemainTextLeftPic.width + 5
                    color:"white"
                    text:"5:00:00"
                    font.family: lcdFont.name
                    font.bold: true
                    font.pointSize: 30
                }
            }
            Rectangle{
                id:timeRemainTextRightWrap
                x:170
                y:timeRemainTextLeftWrap.y
                Image {
                    id: timeRemainTextRightPic
                    source: "resource/pic/gasSpeed.png"
                    width: 30
                    height:30
                }
                Text{
                    id:gasLastSpeedText
                    x:timeRemainTextRightPic.width + 5
                    color:"white"
                    text:"0L/H"
                    font.family: lcdFont.name
                    font.bold: true
                    font.pointSize: 30
                }
            }
            Rectangle{
                id:mileRemainTextRightWrap
                x:330
                y:timeRemainTextLeftWrap.y
                Image {
                    id: mileRemainTextRightPic
                    source: "resource/pic/mileRemain.png"
                    width: 30
                    height:30
                }
                Text{
                    id:mileRemainText
                    x:timeRemainTextRightPic.width + 5
                    color:"white"
                    text:"400KM"
                    font.family: lcdFont.name
                    font.bold: true
                    font.pointSize: 30
                }
            }
        }
        function calculatePercent(){
            var dhy = 9 * 60 * hyPower / 450.0
            currentEnergy = hyCapacity * hyRemain / 30 + liCapacity * (liRemain - 29.6) / 4
            timeRemainCanvas.percent = Math.floor(currentEnergy * 100 / wholeEnergy)
            var remainTime = 5.0 * currentEnergy / wholeEnergy
            var hour = Math.floor(remainTime)
            var minute = Math.floor((remainTime * 60) % 60);
            var second = Math.floor((remainTime * 3600) % 60)
            gasLastSpeedText.text = Math.abs(dhy) + "L/H"
            remainTimeText.text = ("0" + hour).slice(-2) + ":" + ("0" + minute).slice(-2) + ":" + ("0" + second).slice(-2)
            mileRemainText.text = Math.floor(80.0 * remainTime) + "KM"
        }
    }
    MouseArea{
        property variant mousePoint: "0,0"
        anchors.fill: parent
        cursorShape:Qt.PointingHandCursor
        propagateComposedEvents: true
        onClicked: {mouse.accepted = false}
        onPositionChanged: {
            var delta = Qt.point(mouse.x-mousePoint.x, mouse.y-mousePoint.y)
            main.x += delta.x
            main.y += delta.y}
        onPressed: {
            mousePoint = Qt.point(mouse.x,mouse.y)}
    }
    //测试区域
    Timer{
        id:hyPowerPointerWrapperTimer
        interval: 1000
        running: false
        repeat: true
        onTriggered: {
            liPower = 1000
            hyPower = 500
            liRemain = 31.0
            hyRemain = 20.0
            //timeRemainDock.calculatePercent()
        }}
    FontLoader{
        id: lcdFont
        source: "./resource/font/LCD.ttf"
    }
    //函数
    property int hyPower: 0
    property int liPower: 0
    property double hyRemain: 0
    property double liRemain: 0
    function setAllChartData(seriesData, pointData)
    {
        hyPower = pointData["HyPower"]
        liPower = pointData["LiPower"]
        hyRemain = pointData["HyPress"]
        liRemain = pointData["LiVolt"]
        hyRemain = hyRemain > 30 ? 30 : (hyRemain < 0 ? 0 : hyRemain)
        liRemain = liRemain > 33.6 ? 33.6 : (liRemain < 0 ? 0 : liRemain)
        if(isAllGraphStarted && isHyGraphSubWindowExist){
            powerWindowObject.setChartData(seriesData["HyPower"], seriesData["LiPower"], seriesData["AllPower"], seriesData["x"])}
        hyPowerPointerWrapper.pointerAngle = -30 + 240 * hyPower / 1200
        hyPowerIncicator.text = String(hyPower) + "W"
        liPowerPointerWrapper.pointerAngle = -30 + 240 * liPower / 3000
        liPowerIncicator.text = String(liPower) + "W"
        hyRemainPointerWrapper.pointerAngle = -30 + hyRemain * 240 / 30
        hyRemainIncicator.text = String(hyRemain) + "MPa"
        liRemainPointerWrapper.pointerAngle = -30 + (liRemain - 28) * 240 / 6
        liRemainIncicator.text = String(liRemain) + "V"
        timeRemainDock.calculatePercent()
        return 0
    }
    function pauseGraph()
    {
        isGraphPause = !isGraphPause
    }
    function clearGraph(){
        pyRoot.clearGraph()
    }
    onClosing:{
        closeApplication()
    }
}

