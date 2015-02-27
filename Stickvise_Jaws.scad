// ***** PARAMETERS / INPUTS *****

  // external dimensions of jaws
    jaw_length = in_to_mm(3);
    jaw_width = in_to_mm(.5);
    jaw_height = in_to_mm(.25);

  // M3 screw clearance = 3.2mm = .13"
    counterbore_thru_dia = 3.2; 
  // M3 pan head clearance = 7mm = .28"
    counterbore_bore_dia = 7;
  // sets bore depth to 3.4mm or .13" from bottom of jaw
    counterbore_bore_depth = jaw_height - 3.4;

  // set to true to add rectangular step to one side
    add_jaw_step = true;
    jaw_step_height = in_to_mm(.1);
    jaw_step_depth = in_to_mm(.03);

  // set to true to add a HORIZONTAL v-groove to one side
    add_v_groove = true; 
    v_groove_height = in_to_mm(.1);
    v_groove_top_offset = in_to_mm(.025);

  // set to true to add a VERTICAL v to the jaw
    add_vertical_v = false; 
    vertical_v_width = in_to_mm(.3);
  // error if v_depth set equal to jaw height
    vertical_v_depth = in_to_mm(.3); 

  // set to true to add a vertical slot pattern to side1
    add_vertical_slots = false;  
  // set to true to add a vertical slot pattern to side2
    mirror_vertical_slots = false; 
    vertical_slot_pattern_width = in_to_mm(1);
    vertical_slot_pattern_qty = 5;
    vertical_slot_width = in_to_mm(.08);
    vertical_slot_length = in_to_mm(.15);
  // error if slot_depth set equal to jaw height
    vertical_slot_depth = in_to_mm(.2); 
    slot_spacing = vertical_slot_pattern_width/(vertical_slot_pattern_qty-1);
    slot_offset = (jaw_length-vertical_slot_pattern_width-vertical_slot_width)/2;


// ***** SET STL RESOLUTION *****

  // default minimum facet angle degrees
    $fa=0.5;
  // default minimum facet size mm
    $fs=0.2; 


// ***** CREATE GEOMETRY *****

difference()
{
	// main body of the jaw plate
    cube([jaw_length,jaw_width,jaw_height]);

	// counterbores
    translate([jaw_length/2-in_to_mm(1.25), jaw_width/2,0])
      counterbore(counterbore_thru_dia, counterbore_bore_dia, counterbore_bore_depth);
      
    translate([jaw_length/2+in_to_mm(1.25), jaw_width/2,0]) 
      counterbore(counterbore_thru_dia, counterbore_bore_dia, counterbore_bore_depth);
	
	// jaw step
    if(add_jaw_step) 
    {
      jaw_step(jaw_step_height,jaw_step_depth);
    }
	
	// horizontal v-groove
    if(add_v_groove)
    {
      v_groove(v_groove_height, v_groove_top_offset);
    }
    
    if(add_vertical_v)
    {
      color("red") vertical_v(vertical_v_width, vertical_v_depth);
    }
	
	// vertical slots
    if(add_vertical_slots)
    {
      for(i = [0 : vertical_slot_pattern_qty-1])
      {
        vertical_slot(slot_offset+i*slot_spacing,vertical_slot_width,vertical_slot_length,vertical_slot_depth);
      }
    }	
    if(mirror_vertical_slots)
    {
      for(i = [0 : vertical_slot_pattern_qty-1])
      {
        translate([0,-jaw_width-1+vertical_slot_length]) 
          vertical_slot(slot_offset+i*slot_spacing,vertical_slot_width,vertical_slot_length,vertical_slot_depth);
      }
    }
}	


// ***** MODULES AND FUNCTIONS *****

  // creates a counterbore body (must be subtracted from main body)
    module counterbore(thru_dia, bore_dia, bore_depth) 
    {
      union() 
      {
        // thru hole cylinder
        translate([0,0,-1]) 
          cylinder(h=jaw_height+2,d=thru_dia);
        // counterbore cylinder
        translate([0,0,jaw_height-bore_depth]) 
          cylinder(h=bore_depth+1, d=bore_dia);
      }
    }

  // creates a step body (must be subtracted from main body)
    module jaw_step(s_height, s_depth) 
    {
      translate([-1,-1,jaw_height-s_height]) 
        cube([jaw_length+2, s_depth+1, s_height+1]);
    }

  // creates a 90 degree v-groove body (must be subtracted from main body)
    module v_groove(v_height, v_top_offset)
    {
      v_leg = sqrt(pow(v_height,2)/2);
      translate([-1,jaw_width+sqrt(1/2),jaw_height-v_height-v_top_offset-sqrt(1/2)]) 
        rotate([45,0,0]) 
          cube([jaw_length+2, v_leg+1, v_leg+1]);
    }

    module vertical_v(vv_width, vv_depth)
    {
      vv_leg = sqrt((1/2)*pow(vv_width,2));
      translate([jaw_length/2, (-1/2)*vv_width, jaw_height-vv_depth])
        rotate([0,0,45])
          cube([vv_leg, vv_leg, vv_depth+1]);
    }

    module vertical_slot(slot_side_offset, slot_width, slot_length, slot_depth)
    {
      translate([slot_side_offset, jaw_width-slot_length, jaw_height-slot_depth]) 
        cube([slot_width, slot_length+1, slot_depth+1]);
    }

  // inch to millimeter conversion function
    function in_to_mm(inches) = inches * 25.4;