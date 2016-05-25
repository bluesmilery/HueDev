//
//  ControlLightsViewController.swift
//  HueNo1
//
//  Created by Gai on 16/5/17.
//  Copyright © 2016年 Gai. All rights reserved.
//

import UIKit

class ControlLightsViewController: UIViewController {
    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 以开关的形式控制灯的亮灭
    func controlLightsOnOrOff(whichLight: Int, whichSwitch: UISwitch) {
        let light = allLights[whichLight-1] as! PHLight
        let state = light.lightState as PHLightState
        state.on = whichSwitch.on
        let bridgeSendAPI: PHBridgeSendAPI = PHBridgeSendAPI.init()
        bridgeSendAPI.updateLightStateForId(light.identifier, withLightState: state) { (error: [AnyObject]!) in
            if ((error == nil)) {
                print("success")
            } else {
                print("false")
            }
        }
    }
    
    // 以滑动条的形式控制灯的亮度
    func controlLightsBrightness(whichLight: Int, whichSlider: UISlider) {
        whichSlider.continuous = false
        let light = allLights[whichLight-1] as! PHLight
        let state = light.lightState
        state.brightness = Int(whichSlider.value)
        let bridgeSendAPI: PHBridgeSendAPI = PHBridgeSendAPI.init()
        bridgeSendAPI.updateLightStateForId(light.identifier, withLightState: state) { (error: [AnyObject]!) in
            if ((error == nil)) {
                print("success")
            } else {
                print("false")
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
