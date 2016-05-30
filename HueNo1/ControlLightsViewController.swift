//
//  ControlLightsViewController.swift
//  HueNo1
//
//  Created by Gai on 16/5/17.
//  Copyright © 2016年 Gai. All rights reserved.
//

import UIKit

class ControlLightsViewController: UIViewController {
    
    
    let lightModel: String = "LCT001"
    
    @IBOutlet var iv: UIImageView!
    var ima: UIImage!

    // 存储所有灯的实体
    var allLights: Array<AnyObject>!

    // 控制三盏灯亮灭的开关
    @IBOutlet var switchLight1: UISwitch!
    @IBOutlet var switchLight2: UISwitch!
    @IBOutlet var switchLight3: UISwitch!
    @IBAction func switchChangeLight1(sender: AnyObject) {
        controlLightsOnOrOff(1, whichSwitch: switchLight1)
    }
    @IBAction func switchChangeLight2(sender: AnyObject) {
        controlLightsOnOrOff(2, whichSwitch: switchLight2)
    }
    @IBAction func switchChangeLight3(sender: AnyObject) {
        controlLightsOnOrOff(3, whichSwitch: switchLight3)
    }
    
    // 控制三盏灯亮度的滑动条
    @IBOutlet var brightnessLight1: UISlider!
    @IBOutlet var brightnessLight2: UISlider!
    @IBOutlet var brightnessLight3: UISlider!
    @IBAction func brightnessChangeLight1(sender: AnyObject) {
        controlLightsBrightness(1, whichSlider: brightnessLight1)
    }
    @IBAction func brightnessChangeLight2(sender: AnyObject) {
        controlLightsBrightness(2, whichSlider: brightnessLight2)
    }
    @IBAction func brightnessChangeLight3(sender: AnyObject) {
        controlLightsBrightness(3, whichSlider: brightnessLight3)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 得到桥接器中关于灯的数据
        let cache: PHBridgeResourcesCache = PHBridgeResourcesReader.readBridgeResourcesCache()
        allLights = Array(cache.lights.values)
        print("en?")
        
        ima = UIImage.init(named: "map-brightness")
        iv.image = ima
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 以开关的形式控制灯的亮灭
    func controlLightsOnOrOff(whichLight: Int, whichSwitch: UISwitch) {
        let light = allLights[whichLight-1] as! PHLight
        let state: PHLightState = PHLightState.init()
        state.on = whichSwitch.on
        let bridgeSendAPI: PHBridgeSendAPI = PHBridgeSendAPI.init()
        bridgeSendAPI.updateLightStateForId(light.identifier, withLightState: state) { (error: [AnyObject]!) in
            if ((error == nil)) {
                print("success")
            } else {
                print("failure")
            }
        }
    }
    
    // 以滑动条的形式控制灯的亮度
    func controlLightsBrightness(whichLight: Int, whichSlider: UISlider) {
        whichSlider.continuous = false
        let light = allLights[whichLight-1] as! PHLight
        let state: PHLightState = PHLightState.init()
        state.brightness = Int(whichSlider.value)
        let bridgeSendAPI: PHBridgeSendAPI = PHBridgeSendAPI.init()
        bridgeSendAPI.updateLightStateForId(light.identifier, withLightState: state) { (error: [AnyObject]!) in
            if ((error == nil)) {
                print("success")
            } else {
                print("failure")
            }
        }
    }
    
    // 触摸事件
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchPosition = touches.first!.locationInView(iv)
        if (touchPosition.x >= 0 && touchPosition.x <= iv.frame.size.width && touchPosition.y >= 0 && touchPosition.y <= iv.frame.size.height) {
            
            let realPositionX: CGFloat = touchPosition.x / iv.frame.size.width * ima.size.width
            let realPositionY: CGFloat = touchPosition.y / iv.frame.size.height * ima.size.height
            let getColor = ima.getPixelColor(CGPointMake(realPositionX, realPositionY))
            
            print("touchesBegan")
            print(touchPosition)
            print(CGPointMake(realPositionX, realPositionY))
            print(getColor)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchPosition = touches.first!.locationInView(iv)
        if (touchPosition.x >= 0 && touchPosition.x <= iv.frame.size.width && touchPosition.y >= 0 && touchPosition.y <= iv.frame.size.height) {
            
            let realPositionX: CGFloat = touchPosition.x / iv.frame.size.width * ima.size.width
            let realPositionY: CGFloat = touchPosition.y / iv.frame.size.height * ima.size.height
            let getColor = ima.getPixelColor(CGPointMake(realPositionX, realPositionY))

            print("touch")
            print(touchPosition)
            print(CGPointMake(realPositionX, realPositionY))
            print(getColor)
        }        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchPosition = touches.first!.locationInView(iv)
        if (touchPosition.x >= 0 && touchPosition.x <= iv.frame.size.width && touchPosition.y >= 0 && touchPosition.y <= iv.frame.size.height) {
            
            let realPositionX: CGFloat = touchPosition.x / iv.frame.size.width * ima.size.width
            let realPositionY: CGFloat = touchPosition.y / iv.frame.size.height * ima.size.height
            let getColor = ima.getPixelColor(CGPointMake(realPositionX, realPositionY))
            
            print("touchesEnded")
            print(touchPosition)
            print(CGPointMake(realPositionX, realPositionY))
            print(getColor)
            
            let lightColor: UIColor = UIColor.init(red: getColor.red, green: getColor.green, blue: getColor.blue, alpha: getColor.alpha)
            let rgbToXY = PHUtilities.calculateXY(lightColor, forModel: lightModel)
            let xOfXY = rgbToXY.x
            let yOfXY = rgbToXY.y
            controlLightsColor(xOfColor: xOfXY, yOfColor: yOfXY)
            print(rgbToXY)
        }
    }
    
    // 以xy方式改变灯的颜色
    func controlLightsColor(xOfColor xOfColor: CGFloat, yOfColor: CGFloat) {
        let light: PHLight = allLights[3-1] as! PHLight
        let state: PHLightState = PHLightState.init()
        state.x = xOfColor
        state.y = yOfColor
        let bridgeSendAPI: PHBridgeSendAPI = PHBridgeSendAPI.init()
        bridgeSendAPI.updateLightStateForId(light.identifier, withLightState: state) { (error: [AnyObject]!) in
            if ((error == nil)) {
                print("success")
            } else {
                print("failure")
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
}

public extension UIImage {
    
    /**
     获取图片中的像素颜色值
     
     - parameter pos: 图片中的位置
     
     - returns: 颜色值
     */
    func getPixelColor(pos: CGPoint) -> (alpha: CGFloat, red: CGFloat, green: CGFloat, blue: CGFloat) {
        let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.CGImage))
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
//        let r = CGFloat(data[pixelInfo])
//        let g = CGFloat(data[pixelInfo+1])
//        let b = CGFloat(data[pixelInfo+2])
//        let a = CGFloat(data[pixelInfo+3])
        
        return (a,r,g,b)
    }
    
}
