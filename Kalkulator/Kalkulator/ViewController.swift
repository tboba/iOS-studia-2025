//
//  ViewController.swift
//  Kalkulator
//
//  Created by Tymoteusz on 11/08/25.
//

import UIKit

enum CalcOperation {
    case add
    case sub
    case mul
    case div
}

class ViewController: UIViewController {
    
    var input: String = ""
    var result: Double? = nil
    var prevResult: Double = 0.0
    
    var prevOperation: CalcOperation?
    
    @IBOutlet weak var resultsLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func setOperation(operation: CalcOperation) {
        parseInput()
        
        if prevOperation == nil {
            prevResult = result ?? 0.0
        } else {
            handleOperation()
        }
        
        prevOperation = operation
    }
    
    func parseInput() {
        if !input.isEmpty {
            result = Double(input) ?? 0.0
            input = ""
        }
    }
    
    func setResultFromNumber() {
        let integerPart = Int(result!)
        let decimalPart = result! - Double(integerPart)
        
        if decimalPart != 0.0 {
            resultsLabel.text = String(result!)
        } else{
            guard let dotIndex = String(result!).firstIndex(of: ".") else { return }
            let integerPart = String(result!)[..<dotIndex]
            resultsLabel.text = String(integerPart)
        }
    }
    
    func handleOperation() {
        switch prevOperation {
        case .add:
            prevResult += result!
        case .sub:
            prevResult -= result!
        case .mul:
            prevResult *= result!
        case .div:
            if result != 0 && result != nil {
                prevResult /= result ?? 0.0
            } else {
                clear()
                resultsLabel.text = "Err"
                return
            }
        default:
            break
        }
        
        result = prevResult
        setResultFromNumber()
    }
    
    func clear(){
        resultsLabel.text = ""
        input = ""
        result = nil
        prevResult = 0.0
        prevOperation = nil
    }
    
    @IBAction func clearButton(_ sender: Any) {
        clear()
    }
    
    @IBAction func addButton(_ sender: Any) {
        setOperation(operation: CalcOperation.add)
    }
    
    @IBAction func minusButton(_ sender: Any) {
        setOperation(operation: CalcOperation.sub)
    }
    
    @IBAction func multiplyButton(_ sender: Any) {
        setOperation(operation: CalcOperation.mul)
    }
    
    @IBAction func divideButton(_ sender: Any) {
        setOperation(operation: CalcOperation.div)
    }
    
    @IBAction func equalButton(_ sender: Any) {
        parseInput()
        
        if prevOperation == nil {
            print(result!)
            
            setResultFromNumber()
        } else {
            handleOperation()
            prevOperation = nil
        }
    }
    
    @IBAction func strokeButton(_ sender: Any) {
        if input.isEmpty {
            input += "0."
            resultsLabel.text = input
            return
        }
        
        if input.contains(".") {
            return
        } else {
            input += "."
            resultsLabel.text = input
        }
    }
    
    @IBAction func changeSign(_ sender: Any) {
        if !input.isEmpty {
            if input.hasPrefix("-") {
                input.remove(at: input.startIndex)
            }else{
                input = "-" + input
            }
            resultsLabel.text = input
        }
    }
    
    @IBAction func percentButton(_ sender: Any) {
        parseInput()
        result! *= 0.01
        resultsLabel.text = String(result!)
    }
    
    @IBAction func powButton(_ sender: Any) {
        parseInput()
        
        result = pow(result!, 2)
        setResultFromNumber()
    }
    
    @IBAction func logButton(_ sender: Any) {
        parseInput()
        result = log10(result!)
        setResultFromNumber()
    }
    
    func addNumToInput(_ num: Int){
        if input != "0" {
            input += String(num)
            resultsLabel.text = input
        }else{
            input = String(num)
            resultsLabel.text = input
        }
    }
    
    @IBAction func zeroButton(_ sender: Any) {
        addNumToInput(0)
    }
    
    @IBAction func oneButton(_ sender: Any) {
        addNumToInput(1)
    }
    
    @IBAction func twoButton(_ sender: Any) {
        addNumToInput(2)
    }
    
    @IBAction func threeButton(_ sender: Any) {
        addNumToInput(3)
    }
    
    @IBAction func fourButton(_ sender: Any) {
        addNumToInput(4)
    }
    
    @IBAction func fiveButton(_ sender: Any) {
        addNumToInput(5)
    }
    
    @IBAction func sixButton(_ sender: Any) {
        addNumToInput(6)
    }
    
    @IBAction func sevenButton(_ sender: Any) {
        addNumToInput(7)
    }
    
    @IBAction func eightButton(_ sender: Any) {
        addNumToInput(8)
    }
    
    @IBAction func nineButton(_ sender: Any) {
        addNumToInput(9)
    }

}

