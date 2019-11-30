model MainProject

/* Insert your model definition here */

global {
	
	int number_of_people <- 50;
	
	init{
//		create people number:number_of_people;
		create visitor number: number_of_people;
//		create stage number:4;
	}
}

//species stage skills:[moving, fipa] {		
//	int playing <- 0 min: 0 update: playing - 1;
//	float aspect1 <- rnd(0,255)/10;
//	float aspect2 <- float(0);
//	float aspect3 <- float(0);
//	float aspect4 <- float(0);
//	float aspect5 <- float(0);
//	float aspect6 <- float(0);
//	
//	
//	reflex send_inform when: playing = 0 {
//		aspect1 <- rnd(0,255)/10;
//		aspect2 <- rnd(0,255)/10;
//		aspect3 <- rnd(0,255)/10;
//		aspect4 <- rnd(0,255)/10;
//		aspect5 <- rnd(0,255)/10;
//		aspect6 <- rnd(0,255)/10;
//	
//		playing <- rnd(200, 300);
//		write '(Time ' + time + '): ' + name + ' sends an inform message to all participants';
//		do start_conversation to: list(people) protocol: 'fipa-contract-net' performative: 'inform' contents: [aspect1, aspect2, aspect3, aspect4, aspect5, aspect6, playing];
//	}
//	
//	aspect base {
//		float color_ <- aspect1 + aspect2 + aspect3 + aspect4 + aspect5 + aspect6;
//		draw square(5) color: rgb(color_, color_, color_);
//	}
//}


species visitor skills:[moving, fipa] {
	
	// Types:
	// 0 - party
	// 1 - chill
	// 2 - copycat (mimics other behaviours)
	// 3 - journalist
	// 4 - add later
	int type <- rnd(0, 4);
	
	// Attributes:
	float wealth <- rnd(0, 10)/10;
	// can be tired or not tired
	bool tired <- false;
	// can be old or young
	bool old <- false;
	int food_level <- rnd(150, 200) min: 0 update: food_level - 1;
	
	string status <- 'wandering';
	string wish <- nil;
	int wish_satisfaction <- 0;
	
	// ???
	int in_act <- 0 min: 0 update: in_act - 1;
	bool busy <- false;
	
	
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
	
	reflex printInfo when: name = 'visitor0' {
//		festival_map cell <- festival_map grid_at {self.location.x, self.location.x};
		write name;
		write status;
		write wish;
		write wish_satisfaction;
		write '----';
//		write festival_map({self.location.x, self.location.y}).color;
	}
	
	
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
		switch roll {
//			match_between [0, 84] {wish <- nil;}
			match_between [0, 24] {wish <- 'party';}
			match_between [25, 34] {wish <- 'chill';}
			match_between [35, 40] {wish <- 'gamble';}
			default {wish <- 'wander';}
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
				status <- 'wandering';
				wander_point <- self.location;
			}
		}
	}
	
	
	
	
	
	
	
	//	Rendering the visitor:
	
	rgb get_color {
		
		if (name = 'visitor0') {
			return #brown;
		}
		
		if (self.type = 0) {
			return #red;
		} else if (self.type = 1) {
			return #blue;
		} else if (self.type = 2) {
			return #white;
		} else if (self.type = 3) {
			return #yellow;
		} else {
			return #green;
		}
	}
	
	aspect base {
		draw circle(1) color: get_color() border: #black;
		if (name = 'visitor0') {
			draw (status + ', ' + 'wants to ' + wish) color: #blue font: font("Arial", 20 , #bold);	
		}
	}
}

//species people skills:[moving, fipa] {
//	float aspect1 <- rnd(0,255)/10;
//	float aspect2 <- rnd(0,255)/10;
//	float aspect3 <- rnd(0,255)/10;
//	float aspect4 <- rnd(0,255)/10;
//	float aspect5 <- rnd(0,255)/10;
//	float aspect6 <- rnd(0,255)/10;
//	float color_ <- aspect1 + aspect2 + aspect3 + aspect4 + aspect5 + aspect6;
//	
//	float best_deal <- float(99999);
//	point best_deal_p <- nil;
//	int in_act <- 0 min: 0 update: in_act - 1;
//	
//	rgb color <- #green;
//	point targetPoint <- nil;
//	
//	reflex go_wander when: in_act = 0 {
//		targetPoint <- point(rnd(0, 100), rnd(0, 100));
//		best_deal <- float(99999);
//	}
//	
//	reflex receive_inform when: !empty(informs) and in_act = 0 {
//		int tmp_;
//		loop i over: informs {
//			 message proposal <- i;
//		     float val <- abs(color_ - (int(proposal.contents[0]) + int(proposal.contents[1]) + int(proposal.contents[2]) + int(proposal.contents[3]) + int(proposal.contents[4]) + int(proposal.contents[5])));
//		     write "Contents: " + proposal.contents;
//		     write string(val) + " <<<>>> " + best_deal;
//		     if(val < best_deal) {
//		     	best_deal <- val;
//		     	write name + ' chose to go to ' + proposal.sender;
//		     	best_deal_p <- proposal.sender; 
//		     	tmp_ <- int(proposal.contents[6]);
//			 }
//		}
//		targetPoint <- best_deal_p;
//		in_act <- tmp_;
//	}
//	
//	geometry circle_ <- smooth(circle(1), 0.0);
//	aspect base {
//		draw circle(1) color: rgb(color_, color_, color_) depth: 1 border: #green;
//	}
//	
//	reflex beIdle when: targetPoint = nil {
//		do wander speed: 0.1;
//		
//	}
//	
//	reflex moveToTarget when: targetPoint != nil {
//		if(targetPoint = location) {
//			targetPoint <- nil;
//		}
//		do goto target: targetPoint;
//	}
//}

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
//			species stage aspect:base;
//			species people aspect:base;
			species visitor aspect: base;
		}
	}
}