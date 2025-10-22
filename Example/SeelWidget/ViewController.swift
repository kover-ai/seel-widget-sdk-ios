//
//  ViewController.swift
//  SeelWidget_Example
//
//  Created by Developer on 10/11/2025.
//  Copyright (c) 2025 Developer. All rights reserved.
//

import UIKit
import SeelWidget
import SnapKit

class ViewController: UIViewController {
    
    private lazy var wfpView: SeelWFPView = {
        let wfpView = SeelWFPView(frame: .zero)
        wfpView.layer.cornerRadius = 8
        return wfpView
    }()
    
    private lazy var setupButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Setup", for: .normal)
        button.addTarget(self, action: #selector(setup), for: .touchUpInside)
        if #available(iOS 13.0, *) {
            button.backgroundColor = .systemBlue
        } else {
            button.backgroundColor = .blue
        }
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }()
    
    private lazy var updateButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Update", for: .normal)
        button.addTarget(self, action: #selector(update), for: .touchUpInside)
        if #available(iOS 13.0, *) {
            button.backgroundColor = .systemBlue
        } else {
            button.backgroundColor = .blue
        }
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }()
    
    private lazy var eventButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Sent Event", for: .normal)
        button.addTarget(self, action: #selector(sendEvents), for: .touchUpInside)
        if #available(iOS 13.0, *) {
            button.backgroundColor = .systemBlue
        } else {
            button.backgroundColor = .blue
        }
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        if #available(iOS 13.0, *) {
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.hidesWhenStopped = true
            return indicator
        } else {
            let indicator = UIActivityIndicatorView(style: .gray)
            indicator.hidesWhenStopped = true
            return indicator
        }
    }()
    
    private lazy var errorLabel = UILabel()
    
    private lazy var errorSwitch: UISwitch = {
        let switcher = UISwitch()
        switcher.isOn = false
        return switcher
    }()
    
    private lazy var acceptedLabel = UILabel()
    
    private lazy var acceptedSwitch: UISwitch = {
        let switcher = UISwitch()
        switcher.isOn = true
        return switcher
    }()
    
    private lazy var defaultLabel = UILabel()
    
    private lazy var defaultSwitch: UISwitch = {
        let switcher = UISwitch()
        switcher.isOn = true
        return switcher
    }()
    
    private lazy var countLabel = UILabel()
    
    private lazy var countValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.text = "3"
        return label
    }()
    
    private lazy var countStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 1
        stepper.maximumValue = 99
        stepper.stepValue = 1
        stepper.value = 3
        stepper.addTarget(self, action: #selector(countChanged), for: .valueChanged)
        return stepper
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = .lightGray
        
        view.addSubview(wfpView)
        
        view.addSubview(errorLabel)
        view.addSubview(errorSwitch)
        view.addSubview(acceptedLabel)
        view.addSubview(acceptedSwitch)
        view.addSubview(defaultLabel)
        view.addSubview(defaultSwitch)
        view.addSubview(countLabel)
        view.addSubview(countValueLabel)
        view.addSubview(countStepper)
        
        view.addSubview(setupButton)
        view.addSubview(updateButton)
        view.addSubview(eventButton)
        view.addSubview(loadingIndicator)
        
        errorLabel.text = "Error Data"
        
        acceptedLabel.text = "Status Accepted"
        
        defaultLabel.text = "Is Default On"
        
        countLabel.text = "Product Count"
        countValueLabel.text = String(Int(countStepper.value))
        
        wfpView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(wfpView.snp.bottom).offset(16)
            make.left.equalTo(wfpView)
        }
        errorSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(errorLabel)
            make.right.equalTo(wfpView)
        }
        acceptedLabel.snp.makeConstraints { make in
            make.top.equalTo(errorLabel.snp.bottom).offset(16)
            make.left.equalTo(wfpView)
        }
        acceptedSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(acceptedLabel)
            make.right.equalTo(wfpView)
        }
        defaultLabel.snp.makeConstraints { make in
            make.top.equalTo(acceptedLabel.snp.bottom).offset(12)
            make.left.equalTo(wfpView)
        }
        defaultSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(defaultLabel)
            make.right.equalTo(wfpView)
        }
        countLabel.snp.makeConstraints { make in
            make.top.equalTo(defaultLabel.snp.bottom).offset(12)
            make.left.equalTo(wfpView)
        }
        countStepper.snp.makeConstraints { make in
            make.centerY.equalTo(countLabel)
            make.right.equalTo(wfpView)
        }
        countValueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(countLabel)
            make.right.equalTo(countStepper.snp.left).offset(-8)
        }
        setupButton.snp.makeConstraints { make in
            make.top.equalTo(countLabel.snp.bottom).offset(16)
            make.left.equalTo(wfpView)
        }
        updateButton.snp.makeConstraints { make in
            make.top.equalTo(countLabel.snp.bottom).offset(16)
            make.right.equalTo(wfpView)
        }
        eventButton.snp.makeConstraints { make in
            make.top.equalTo(setupButton.snp.bottom).offset(16)
            make.left.equalTo(wfpView)
        }
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        wfpView.optedIn = { optedIn, quote in
            print("optedIn:\(optedIn) price:\(quote?.price ?? 0)")
        }
        SeelWidgetSDK.shared.configure(apiKey: TestDatas.apiKey, environment: .development)
    }
    
    @objc func setup() {
        print("setting up...")
        if let quotes = TestDatas.getQuote(acceptedSwitch.isOn, defaultOn: defaultSwitch.isOn, itemCount: Int(countStepper.value), error: errorSwitch.isOn) {
            print("creating quote...")
            TestDatas.printJSON(quotes, label: "Quotes JSON")
            loading(true)
            wfpView.setup(quotes) { [weak self] result in
                self?.loading(false)
                TestDatas.printResult(result, successLabel: "Setup Success JSON")
            }
        }
    }
    
    @objc func update() {
        print("updating...")
        if let quotes = TestDatas.getQuote(acceptedSwitch.isOn, defaultOn: defaultSwitch.isOn, itemCount: Int(countStepper.value), error: errorSwitch.isOn) {
            print("creating quote...")
            TestDatas.printJSON(quotes, label: "Quotes JSON")
            loading(true)
            wfpView.updateWidgetWhenChanged(quotes) { [weak self] result in
                self?.loading(false)
                TestDatas.printResult(result, successLabel: "Update Success JSON")
            }
        }
    }
    
    @objc func countChanged() {
        countValueLabel.text = String(Int(countStepper.value))
    }
    
    @objc func sendEvents() {
        let event = TestDatas.getEvent()
        print("sending event...")
        TestDatas.printJSON(event, label: "Event JSON")
        loading(true)
        SeelWidgetSDK.shared.createEvents(event) { [weak self] result in
            self?.loading(false)
            TestDatas.printResult(result, successLabel: "Event Success JSON")
        }
    }
    
    func loading(_ loading: Bool) {
        // Handle loading state
        if loading {
            view.isUserInteractionEnabled = false
            loadingIndicator.startAnimating()
        } else {
            view.isUserInteractionEnabled = true
            loadingIndicator.stopAnimating()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

