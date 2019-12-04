model MainProject

/* Insert your model definition here */

global {
	
	int number_of_people <- 50;
	
	int total_conversations <- 0;
	int total_denies <- 0;
	int partied <- 0;
	int chilled <- 0;
	int ate <- 0;
	int gambled <- 0;
	
	init{
		create visitor number: number_of_people;
	}
}

species visitor skills:[moving, fipa] {
	
	string get_type {
		switch rnd(0, 99) {
			match_between [0, 40] {return 'average';}	// 41% for average
			match_between [41, 58] {return 'party';}	// 18% for party
			match_between [59, 76] {return 'chill';}	// 18% for chill
			match_between [77, 94] {return 'gambler';}	// 18% for gambler
			match_between [95, 99] {return 'weirdo';}	// 5% for weirdo
			default {return 'weirdo';}
		}
	}
	string agent_type <- name = 'visitor0' ? 'average' : get_type();
	
	// Attributes (at least 3):
	int wealth <- rnd(0, 9);
	bool talkative <- flip(0.5);
	int age <- rnd(18, 50);
	
	int food_level <- rnd(150, 200) min: 0 update: food_level - 1;
	
	string status <- 'wandering';
	
	string wish <- nil;
	int wish_satisfaction <- 0;
	
	point target_point <- nil;
	point wander_point <- self.location;

	reflex go_wander when: target_point = nil and wish = 'wander' {
		// to keep it within the grid limits:
		float x_wander_min <- (self.location.x - 10) < 0 ? 0 : self.location.x - 10;
		float x_wander_max <- (self.location.x + 10) > 100 ? 100 : self.location.x + 10;
		float y_wander_min <- (self.location.y - 10) < 0 ? 0 : self.location.y - 10;
		float y_wander_max <- (self.location.y + 10) > 100 ? 100 : self.location.y + 10;		
		
		wish_satisfaction <- wish_satisfaction + 1;
		if (wish_satisfaction > 30 and self.location = wander_point) {
			wish <- nil;
			wander_point <- self.location;
			wish_satisfaction <- 0;
			return;
		}
		
		if (self.location = wander_point) {
			wander_point <- point(rnd(x_wander_min, x_wander_max), rnd(y_wander_min, y_wander_max));
		}
		do goto target: wander_point;
	}
	
	reflex moveToTarget when: target_point != nil {
		if(target_point = location) {
			target_point <- nil;
		}
		do goto target: target_point;
	}
	
//	reflex printInfo when: name = 'visitor0' {
////		festival_map cell <- festival_map grid_at {self.location.x, self.location.x};
//		write name + ', ' + agent_type + ', ' + status;
//		write wish + ', ' + wish_satisfaction;
//		write '----';
////		write festival_map({self.location.x, self.location.y}).color;
//	}
	
	
	reflex eat when: food_level = 0 {
		// food is gray
		if (status != 'walking to eat') {
			// this quadrant is food area
			target_point <- {rnd(0, 50), rnd(50, 100)};	
		}
		status <- 'walking to eat';
		if (self.location = target_point) {
			target_point <- nil;
			food_level <- rnd(150, 200);
			ate <- ate + 1;
			status <-'wandering';
			wander_point <- self.location;
		}
	}
	
	reflex get_a_wish when: wish = nil {
		int roll <- rnd(0, 99);
		// 70% to wander,
		// 10% to party,
		// 10% to chill,
		// and 10% to gamble
		switch agent_type {
			match 'average' {
				switch roll {
					match_between [0, 24] {wish <- 'party';}		// 25% to party
					match_between [25, 34] {wish <- 'chill';}		// 10% to chill
					match_between [35, 39] {wish <- 'gamble';}		// 5% to gamble
					default {wish <- 'wander';}						// 60% to wander
				}
			}
			match 'party' {
				switch roll {
					match_between [0, 39] {wish <- 'party';}		// 40% to party
					match_between [40, 54] {wish <- 'chill';}		// 15% to chill
//					match_between [35, 39] {wish <- 'gamble';}		// 0% to gamble
					default {wish <- 'wander';}						// 45% to wander
				}
			}
			match 'chill' {
				switch roll {
					match_between [0, 14] {wish <- 'party';}		// 15% to party
					match_between [15, 49] {wish <- 'chill';}		// 35% to chill
					match_between [50, 59] {wish <- 'gamble';}		// 10% to gamble
					default {wish <- 'wander';}						// 40% to wander
				}
			}
			match 'gambler' {
				switch roll {
					match_between [0, 9] {wish <- 'party';}		// 10% to party
					match_between [10, 19] {wish <- 'chill';}		// 10% to chill
					match_between [20, 59] {wish <- 'gamble';}		// 30% to gamble
					default {wish <- 'wander';}						// 40% to wander
				}
			}
			match 'weirdo' {
				switch roll {
					match_between [0, 4] {wish <- 'party';}		// 5% to party
					match_between [5, 9] {wish <- 'chill';}		// 5% to chill
					match_between [10, 14] {wish <- 'gamble';}		// 5% to gamble
					default {wish <- 'wander';}						// 85% to wander
				}
			}
			default {}
		}
	}
	
	reflex party when: wish = 'party' and food_level != 0 {
		if (status != 'walking to party' and status != 'partying') {
			// this quadrant is food area
			target_point <- {rnd(0, 50), rnd(0, 50)};	
		}
		
		if (status != 'partying') {
			status <- 'walking to party';	
		}
		
		if (self.location = target_point) {
			target_point <- nil;
			status <-'partying';
		}
		
		if (status = 'partying') {
			wish_satisfaction <- wish_satisfaction + 1;
			do wander;
			
			if (wish_satisfaction = 30) {
				wish_satisfaction <- 0;
				wish <- nil;
				partied <- partied + 1;
				status <- 'wandering';
				wander_point <- self.location;
			}
		}
		
	}
	
	reflex chill when: wish = 'chill' and food_level != 0 {
		if (status != 'walking to chill' and status != 'chilling') {
			// this quadrant is food area
			target_point <- {rnd(50, 100), rnd(0, 50)};	
		}
		
		if (status != 'chilling') {
			status <- 'walking to chill';	
		}
		
		if (self.location = target_point) {
			target_point <- nil;
			status <-'chilling';
		}
		
		if (status = 'chilling') {
			wish_satisfaction <- wish_satisfaction + 1;
			do wander;
			
			if (wish_satisfaction = 30) {
				wish_satisfaction <- 0;
				wish <- nil;
				chilled <- chilled + 1;
				status <- 'wandering';
				wander_point <- self.location;
			}
		}
	}
	
	reflex gamble when: wish = 'gamble' and food_level != 0 {
		if (status != 'walking to gamble' and status != 'gambling') {
			// this quadrant is food area
			target_point <- {rnd(50, 100), rnd(50, 100)};	
		}
		
		if (status != 'gambling') {
			status <- 'walking to gamble';	
		}
		
		if (self.location = target_point) {
			target_point <- nil;
			status <-'gambling';
		}
		
		if (status = 'gambling') {
			wish_satisfaction <- wish_satisfaction + 1;
			do wander;
			
			if (wish_satisfaction = 30) {
				wish_satisfaction <- 0;
				wish <- nil;
				gambled <- gambled + 1;
				status <- 'wandering';
				wander_point <- self.location;
			}
		}
	}
	
	// name, agent_type, age, wealth, talkative
	//   0        1       2     3         4
	reflex answer_visitor when: !empty(informs) {
		switch agent_type {
			match 'average' {
//				if (name = 'visitor0') {
//					write '---';
//					write 'last informs: ' + informs[length(informs) - 1];	
//				}
//				write informs;
				// average person
				message one_inform <- informs[length(informs) - 1];
				
				switch festival_map({self.location.x, self.location.y}).color {
					match #white {
						// party
						if (name = 'visitor0') {write '' + one_inform.contents[0] +  '(' + one_inform.contents[2] + ') wants to party with me!';}
						if (abs(int(one_inform.contents[2]) - age) < 10 and one_inform.contents[1] != 'weirdo') {
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							if (name = 'visitor0') {write 'PARTY!';}
						} else {
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							if (name = 'visitor0') {write 'No, yuck.';}
						}
						do end_conversation message: one_inform contents: ['Action'];
						
					}
					match #darkgray {
						// chill
						if (name = 'visitor0') {write '' + one_inform.contents[0] +  '(' + one_inform.contents[4] + ') wants to chill with me!';}
						if ((one_inform.contents[4] = string(talkative)) and one_inform.contents[1] != 'weirdo') {
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							if (name = 'visitor0') {write 'Chillax time it is!';}
						} else {
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							if (name = 'visitor0') {write 'No, our personalities dont match.';}
						}
						do end_conversation message: one_inform contents: ['Action'];
					}
					match #gray {
						// food
						if (name = 'visitor0') {write '' + one_inform.contents[0] +  '(' + one_inform.contents[1] + ') wants to eat with me!';}
						if (one_inform.contents[1] = agent_type) {
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							if (name = 'visitor0') {write 'Then we shall feast!';}
						} else {
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							if (name = 'visitor0') {write 'No, wrong type.';}
						}
						do end_conversation message: one_inform contents: ['Action'];
					}
					match #black {
						// gambling
						if (name = 'visitor0') {write '' + one_inform.contents[0] +  '(' + one_inform.contents[3] + ') wants to gamble with me!';}
						if (int(one_inform.contents[3]) > 5 and wealth > 5) {
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							if (name = 'visitor0') {write 'Lets play then!';}
						} else {
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							if (name = 'visitor0') {write 'No, one of us is too poor.';}
						}
						do end_conversation message: one_inform contents: ['Action'];
					}
				}
				
//				if (name = 'visitor0') {
//					write '' + one_inform.contents[0] +  '(' + one_inform.contents[1] + ') has proposed to...';
//				}
			}
			match 'party' {
				// party person
				message one_inform <- informs[length(informs) - 1];
				
				switch festival_map({self.location.x, self.location.y}).color {
					match #white {
						// party
						if (name = 'visitor0') {write '' + one_inform.contents[0] +  '(' + one_inform.contents[2] + ') wants to party with me!';}
						do agree message: one_inform contents: ['Yes'];
						total_conversations <- total_conversations + 1;
						if (name = 'visitor0') {write 'PARTY!';}
						do end_conversation message: one_inform contents: ['Action'];
						
					}
					match #darkgray {
						// chill
						if (name = 'visitor0') {write '' + one_inform.contents[0] +  '(' + one_inform.contents[4] + ') wants to chill with me!';}
						if ((one_inform.contents[4] = string(talkative)) and one_inform.contents[1] != 'weirdo') {
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							if (name = 'visitor0') {write 'Chillax time it is!';}
						} else {
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							if (name = 'visitor0') {write 'No, our personalities dont match.';}
						}
						do end_conversation message: one_inform contents: ['Action'];
					}
					match #gray {
						// food
						if (name = 'visitor0') {write '' + one_inform.contents[0] +  '(' + one_inform.contents[1] + ') wants to eat with me!';}
						if (one_inform.contents[1] = agent_type) {
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							if (name = 'visitor0') {write 'Then we shall feast!';}
						} else {
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							if (name = 'visitor0') {write 'No, wrong type.';}
						}
						do end_conversation message: one_inform contents: ['Action'];
					}
					match #black {
						// gambling
						if (name = 'visitor0') {write '' + one_inform.contents[0] +  '(' + one_inform.contents[3] + ') wants to gamble with me!';}
						if (int(one_inform.contents[3]) > 5 and wealth > 5) {
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							if (name = 'visitor0') {write 'Lets play then!';}
						} else {
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							if (name = 'visitor0') {write 'No, one of us is too poor.';}
						}
						do end_conversation message: one_inform contents: ['Action'];
					}
				}
			}
			match 'chill' {
				// chill person
				message one_inform <- informs[length(informs) - 1];
				
				switch festival_map({self.location.x, self.location.y}).color {
					match #white {
						// party
						if (name = 'visitor0') {write '' + one_inform.contents[0] +  '(' + one_inform.contents[2] + ') wants to party with me!';}
						do cancel message: one_inform contents: ['No'];
						total_denies <- total_denies + 1;
						if (name = 'visitor0') {write 'Ah, partying is too much action...';}
						do end_conversation message: one_inform contents: ['Action'];
						
					}
					match #darkgray {
						// chill
						if (name = 'visitor0') {write '' + one_inform.contents[0] +  '(' + one_inform.contents[4] + ') wants to chill with me!';}
						do agree message: one_inform contents: ['Yes'];
						total_conversations <- total_conversations + 1;
						if (name = 'visitor0') {write 'Chill? Chill!';}
						do end_conversation message: one_inform contents: ['Action'];
					}
					match #gray {
						// food
						if (name = 'visitor0') {write '' + one_inform.contents[0] +  '(' + one_inform.contents[1] + ') wants to eat with me!';}
						if (one_inform.contents[1] = agent_type) {
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							if (name = 'visitor0') {write 'Then we shall feast!';}
						} else {
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							if (name = 'visitor0') {write 'No, wrong type.';}
						}
						do end_conversation message: one_inform contents: ['Action'];
					}
					match #black {
						// gambling
						if (name = 'visitor0') {write '' + one_inform.contents[0] +  '(' + one_inform.contents[3] + ') wants to gamble with me!';}
						if (int(one_inform.contents[3]) > 3 and wealth > 6) {
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							if (name = 'visitor0') {write 'Lets play then! I have some extra money.';}
						} else {
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							if (name = 'visitor0') {write 'No, one of us is too poor.';}
						}
						do end_conversation message: one_inform contents: ['Action'];
					}
				}
			}
			match 'gambler' {
				// gambler person
				message one_inform <- informs[length(informs) - 1];
				
				switch festival_map({self.location.x, self.location.y}).color {
					match #white {
						// party
						if (name = 'visitor0') {write '' + one_inform.contents[0] +  '(' + one_inform.contents[2] + ') wants to party with me!';}
						if (abs(int(one_inform.contents[2]) - age) < 10 and one_inform.contents[1] != 'weirdo') {
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							if (name = 'visitor0') {write 'PARTY!';}
						} else {
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							if (name = 'visitor0') {write 'No, yuck.';}
						}
						do end_conversation message: one_inform contents: ['Action'];
						
					}
					match #darkgray {
						// chill
						if (name = 'visitor0') {write '' + one_inform.contents[0] +  '(' + one_inform.contents[4] + ') wants to chill with me!';}
						if ((one_inform.contents[4] = string(talkative)) and one_inform.contents[1] != 'weirdo' and wealth = 0) {
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							if (name = 'visitor0') {write 'Guess I will chill, I am too poor to gamble...';}
						} else {
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							if (name = 'visitor0') {write 'No, our personalities dont match.';}
						}
						do end_conversation message: one_inform contents: ['Action'];
					}
					match #gray {
						// food
						if (name = 'visitor0') {write '' + one_inform.contents[0] +  '(' + one_inform.contents[1] + ') wants to eat with me!';}
						if (one_inform.contents[1] = agent_type) {
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							if (name = 'visitor0') {write 'Then we shall feast!';}
						} else {
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							if (name = 'visitor0') {write 'No, wrong type.';}
						}
						do end_conversation message: one_inform contents: ['Action'];
					}
					match #black {
						// gambling
						if (name = 'visitor0') {write '' + one_inform.contents[0] +  '(' + one_inform.contents[3] + ') wants to gamble with me!';}
						if (int(one_inform.contents[3]) > 1 and wealth > 0) {
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							if (name = 'visitor0') {write 'Oh yes. GAMBLING!';}
						} else {
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							if (name = 'visitor0') {write 'No, one of us is too poor.';}
						}
						do end_conversation message: one_inform contents: ['Action'];
					}
				}
			}
			match 'weirdo' {
				// weird person
				message one_inform <- informs[length(informs) - 1];
				
				switch festival_map({self.location.x, self.location.y}).color {
					match #white {
						// party
						if (name = 'visitor0') {write '' + one_inform.contents[0] +  '(' + one_inform.contents[2] + ') wants to party with me!';}
						do agree message: one_inform contents: ['Yes'];
						total_conversations <- total_conversations + 1;
						if (name = 'visitor0') {write 'WEIRD TIME!';}
						do end_conversation message: one_inform contents: ['Action'];
						
					}
					match #darkgray {
						// chill
						if (name = 'visitor0') {write '' + one_inform.contents[0] +  '(' + one_inform.contents[4] + ') wants to chill with me!';}
						do agree message: one_inform contents: ['Yes'];
						total_conversations <- total_conversations + 1;
						if (name = 'visitor0') {write 'WIERD TIME!';}
						do end_conversation message: one_inform contents: ['Action'];
					}
					match #gray {
						// food
						if (name = 'visitor0') {write '' + one_inform.contents[0] +  '(' + one_inform.contents[1] + ') wants to eat with me!';}
						if (one_inform.contents[1] = agent_type) {
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							if (name = 'visitor0') {write 'Then we shall feast!';}
						} else {
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							if (name = 'visitor0') {write 'No, wrong type.';}
						}
						do end_conversation message: one_inform contents: ['Action'];
					}
					match #black {
						// gambling
						if (name = 'visitor0') {write '' + one_inform.contents[0] +  '(' + one_inform.contents[3] + ') wants to gamble with me!';}
						if (int(one_inform.contents[3]) > 5) {
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							if (name = 'visitor0') {write 'Only if you are paying!';}
						} else {
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							if (name = 'visitor0') {write 'No, they are too poor.';}
						}
						do end_conversation message: one_inform contents: ['Action'];
					}
				}
			}
		}
	}
	
	visitor asked_last_time <- nil;
	reflex ask_visitor when: food_level != 0 and !(empty(visitor at_distance 5)) {
		switch agent_type {
			match 'average' {
				bool should_ask <- flip(0.3);
				if (should_ask) {
					list<visitor> nearby_visitors <- visitor at_distance 5;
					visitor selected_visitor <- nearby_visitors[rnd(0, length(nearby_visitors) - 1)];
					if (asked_last_time != selected_visitor) {
						do start_conversation to: [selected_visitor] protocol: 'fipa-contract-net' performative: 'inform' contents: [name, agent_type, age, wealth, talkative];	
					}
					asked_last_time <- selected_visitor;
				} else {
					asked_last_time <- visitor at_distance 5 at 0;
				}
			}
			match 'party' {
				bool should_ask <- flip(0.5);
				if (should_ask) {
					list<visitor> nearby_visitors <- visitor at_distance 5;
					visitor selected_visitor <- nearby_visitors[rnd(0, length(nearby_visitors) - 1)];
					if (asked_last_time != selected_visitor) {
						do start_conversation to: [selected_visitor] protocol: 'fipa-contract-net' performative: 'inform' contents: [name, agent_type, age, wealth, talkative];	
					}
					asked_last_time <- selected_visitor;	
				} else {
					asked_last_time <- visitor at_distance 5 at 0;
				}
			}
			match 'chill' {
				bool should_ask <- flip(0.15);
				if (should_ask) {
					list<visitor> nearby_visitors <- visitor at_distance 5;
					visitor selected_visitor <- nearby_visitors[rnd(0, length(nearby_visitors) - 1)];
					if (asked_last_time != selected_visitor) {
						do start_conversation to: [selected_visitor] protocol: 'fipa-contract-net' performative: 'inform' contents: [name, agent_type, age, wealth, talkative];	
					}
					asked_last_time <- selected_visitor;	
				} else {
					asked_last_time <- visitor at_distance 5 at 0;
				}
			}
			match 'gambler' {
				bool should_ask <- flip(0.1);
				if (should_ask) {
					list<visitor> nearby_visitors <- visitor at_distance 5;
					visitor selected_visitor <- nearby_visitors[rnd(0, length(nearby_visitors) - 1)];
					if (asked_last_time != selected_visitor) {
						do start_conversation to: [selected_visitor] protocol: 'fipa-contract-net' performative: 'inform' contents: [name, agent_type, age, wealth, talkative];	
					}
					asked_last_time <- selected_visitor;	
				} else {
					asked_last_time <- visitor at_distance 5 at 0;
				}
			}
			match 'weirdo' {
				bool should_ask <- flip(0.9);
				if (should_ask) {
					list<visitor> nearby_visitors <- visitor at_distance 5;
					visitor selected_visitor <- nearby_visitors[rnd(0, length(nearby_visitors) - 1)];
					if (asked_last_time != selected_visitor) {
						do start_conversation to: [selected_visitor] protocol: 'fipa-contract-net' performative: 'inform' contents: [name, agent_type, age, wealth, talkative];	
					}
					asked_last_time <- selected_visitor;	
				}
			}
		}
	}
	
	
	
	//	Rendering the visitor:
	
	rgb get_color {
		if (self.agent_type = 'party') {
			return #white;
		} else if (self.agent_type = 'chill') {
			return #darkgray;
		} else if (self.agent_type = 'average') {
			return #green;
		} else if (self.agent_type = 'gambler') {
			return #black;
		} else {
			// for 'weirdo'
			return #red;
		}
	}
	
	aspect base {
		draw circle(1) color: get_color() border: get_color() = #white ? #black : #white;
		if (name = 'visitor0') {
			draw (status + ', ' + 'wants to ' + wish + ', ' + agent_type + ', ' + wealth + '$, ' + age + 'y.o., ' + talkative) color: #blue font: font("Arial", 20 , #bold);
		}
	}
}

grid festival_map width: 2 height: 2 neighbors: 4 {
//    rgb color <- rgb(255, 255, 255) ;
	rgb get_color {
		if (grid_x = 0) {
			if (grid_y = 0) {
				return #white; 	// party area
			} else {
				return #gray; // food area
			}
		} else {
			if (grid_y = 0) {
				return #darkgray; // relax area
			} else {
				return #black; // casino area
			}
		}
	}

    rgb color <- get_color();
}

experiment my_experiment type: gui {
//	parameter "Number of visitors" var: number_of_people;
	output {
		display map_3D type: opengl{
			grid festival_map lines: #black;
			species visitor aspect: base;
		}
		
		display chart {
        	chart "Chart1" type: series style: spline {
//     		   	data "Total amount of conversations" value: total_conversations color: #green;
//        		data "Total amount of denied conversations" value: total_denies color: #red;
        		data 'Partied' value: partied color: #green;
        		data 'Chilled' value: chilled color: #red;
        		data 'Ate' value: ate color: #blue;
        		data 'Gambled' value: gambled color: #yellow;
        	}
    	}
	}
}