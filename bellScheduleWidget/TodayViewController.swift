//
//  TodayViewController.swift
//  bellScheduleWidget
//
//  Created by Ari Stassinopoulos on 8/14/16.
//  Copyright © 2016 Stassinopoulos. All rights reserved.
//
import UIKit
import NotificationCenter
import BellScheduleDataKit

class TodayViewController: UIViewController, NCWidgetProviding {
	
	
	@IBOutlet weak var startTimeLabel: UILabel!
	@IBOutlet weak var endTimeLabel: UILabel!
	@IBOutlet weak var classLabel: UILabel!
	@IBOutlet weak var nextClassLabel: UILabel!
	var isWeekend = false;
	var hasPeriod = false;
	
	override func viewDidLoad() {
		super.viewDidLoad()
		determineWeekend()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated);
		self.view.backgroundColor = Settings.getColour();
	}
	func determineWeekend() {
		let weekday = Today(Date()).weekday;
		if weekday == "SAT" || weekday == "SUN" {
			isWeekend = true;
			return;
		}
	}
	func determineHasPeriod() {
		let hasPeriod = CurrentPeriod().isCurrentPeriod
		self.hasPeriod = hasPeriod
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func widgetPerformUpdate(completionHandler: @escaping ((NCUpdateResult) -> Void)) {
		update()
		SpecialTimings.lazyCheckForSpecialTimings(for: Date()) { (areSpecialTimings, error) in
			LocalNotifications.clearNotifications();
			LocalNotifications.registerNotificationsForWeek(after: Date());
			DispatchQueue.main.async {
				self.update()
			}
		}
		
	}
	func update() {
		self.determineWeekend()
		self.determineHasPeriod()
		if self.isWeekend || !self.hasPeriod {
			self.populateEmpty(middle: "No class.")
		}
		if self.hasPeriod {
			self.populateWithTime();
		}
		self.view.backgroundColor = Settings.getColour();
		UIView.animate(withDuration: 0.5, animations: {
			self.view.backgroundColor = Settings.getColour()
			if(Settings.getColourType() == .white) {
				print("these should be running");
				[self.startTimeLabel, self.nextClassLabel, self.endTimeLabel, self.classLabel].forEach({ $0.textColor = UIColor.black;});
			} else {
				self.endTimeLabel.textColor = .white;
				[self.startTimeLabel, self.nextClassLabel,self.classLabel].forEach {$0.textColor = .groupTableViewBackground}
			}
		});
	}
	func populateEmpty(middle: String) {
		startTimeLabel!.text = "";
		classLabel!.text = "";
		nextClassLabel!.text = "";
		endTimeLabel!.text = middle;
	}
	
	func populateWithTime() {
		let customSchedule = Settings.getCustomSchedule();
		let periodOffset = CurrentPeriod().periodOffset
		let currentTimings = CurrentTimings(Date()).currentTimings;
		let period = currentTimings[periodOffset];
		let startTime = DisplayTime(period.0).resolved;
		let endTime = DisplayTime(period.1).resolved;
		let label = customSchedule.replaceWithCustomScheduleString(period.2);
		startTimeLabel!.text = startTime;
		endTimeLabel!.text = endTime;
		classLabel!.text = label;
		if currentTimings.count > periodOffset + 1 {
			let nextPeriod = currentTimings[periodOffset + 1];
			let nextStart = DisplayTime(nextPeriod.0).resolved;
			let nextEnd = DisplayTime(nextPeriod.1).resolved;
			let nextLabel = customSchedule.replaceWithCustomScheduleString(nextPeriod.2);
			nextClassLabel!.text = "NEXT: \(nextLabel) (\(nextStart) – \(nextEnd))"
		} else {
			nextClassLabel!.text = ""
		}
	}
	
	@IBAction func InfoButtonPressed(_ sender: AnyObject) {
		self.extensionContext?.open(URL(string:"bellSchedule://")!, completionHandler: {_ in
		})
	}
	
}
