//
//  ViewController.swift
//  Translate
//
//  Created by Robert O'Connor on 16/10/2015.
//  Copyright © 2015 WIT. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    @IBOutlet weak var textToTranslate: UITextView!
    @IBOutlet weak var translatedText: UITextView!
    @IBOutlet weak var pickerSelection: UITextField!
    @IBOutlet weak var picker: UIPickerView!
    
    
    //this takes the text from the translated box and turns it to speech
    @IBAction func textToSpeech(sender: UIButton) {
        myUtterance = AVSpeechUtterance(string: textView.text)
        myUtterance.rate = 0.3
        synth.speakUtterance(myUtterance)
    }
    
    @IBOutlet weak var textView: UITextView!
    
    //synth holds a reference to an AVSpeechSynthesizer instance
    //myUtterance holds the string to turn into speech
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    
    var languages = ["French","Irish","Turkish"]
    
    override func viewDidLoad() {
        //Set the default language to french
        pickerSelection.text = "French"
        super.viewDidLoad()
        
        //Sets the background color
        self.view.backgroundColor = UIColor(red: 50/255, green: 100/255, blue: 160/255, alpha: 0.3)
        
        // Connect data:
        self.picker.delegate = self
        self.picker.dataSource = self
        
        //Rounds the corners of the text boxes
        textToTranslate.layer.cornerRadius = 6.0;
        translatedText.layer.cornerRadius = 6.0;
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true); super.touchesBegan(touches, withEvent: event)
        //To dismiss the keyboard
    }
    
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return languages[row]
    }
    
    //Sets the font size, font and text color.
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = languages[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 16.0)!,NSForegroundColorAttributeName:UIColor.whiteColor()])
        return myTitle
    }
    // Capture the picker view selection
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        
        pickerSelection.text = languages[row]
        
    }
    
    
    @IBAction func translate(sender: AnyObject) {
        
        let str = textToTranslate.text
        let escapedStr = str.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        var langStr = ("en|fr").stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        if(pickerSelection.text == "French")
        {
            langStr = ("en|fr").stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        }
        else if(pickerSelection.text == "Irish")
        {
            langStr = ("en|ga").stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        }
        else
        {
             langStr = ("en|tr").stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        }
        
        
        
        let urlStr:String = ("http://api.mymemory.translated.net/get?q="+escapedStr!+"&langpair="+langStr!)
        
        let url = NSURL(string: urlStr)
        
        let request = NSURLRequest(URL: url!)// Creating Http Request
        
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.startAnimating()
        
        var result = "<Translation Error>"
        
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { response, data, error in
            
            indicator.stopAnimating()
            
            if let httpResponse = response as? NSHTTPURLResponse {
                if(httpResponse.statusCode == 200){
                    
                    let jsonDict: NSDictionary!=(try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
                    
                    if(jsonDict.valueForKey("responseStatus") as! NSNumber == 200){
                        let responseData: NSDictionary = jsonDict.objectForKey("responseData") as! NSDictionary
                        
                        result = responseData.objectForKey("translatedText") as! String
                    }
                }
                
                self.translatedText.text = result
            }
        }
        
    }
}

