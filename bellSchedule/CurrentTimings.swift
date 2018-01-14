//
//  CurrentTimings.swift
//  bellSchedule
//
//  Created by Ari Stassinopoulos on 8/13/16.
//  Copyright © 2016 Stassinopoulos. All rights reserved.
//

import Foundation
public class CurrentTimings {
	public var currentTimings:[(String, String, String)];
	public init() {
		let dayOfTheWeek = Today().weekday;
		let dateString = Today().dateString;
		if(SpecialTimings.getSpecialTimings() != nil) {
			currentTimings = SpecialTimings.getSpecialTimings() ?? [(String, String, String)]();
			return;
		}
		/*DAYS OFF 2018 [*/
		if(dateString == "15 JAN 2018") {
			currentTimings = [];
		} else
		/*] END DAYS OFF 2018*/
		if(dayOfTheWeek == "MON" || dayOfTheWeek == "TUE" || dayOfTheWeek == "THU") {
			currentTimings = Timings.scheduleMondayTuesdayThursday;
		} else if(dayOfTheWeek == "WED") {
			currentTimings = Timings.scheduleWednesday;
		} else if(dayOfTheWeek == "FRI") {
			currentTimings = Timings.scheduleFriday;
		} else {
			currentTimings = [];
		}
	}
}
