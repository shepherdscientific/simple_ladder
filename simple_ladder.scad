// baseplate constants
screwhole_offset = 15;
screwhole_radius = 2.5;
baseplate_x = 175;
baseplate_y = 95;
platethickness=3;
piperadius=15;
// ladder constants
start_depth = 110;
incline_deg = 1;
width = 320+(piperadius*2);
step_spacing=300;       // space between steps
num_steps=35;
num_segments=5;
steps_seg=num_steps/num_segments;
echo("    steps per segment : ",steps_seg);
total_length = (1+num_steps)*step_spacing;
segment_length = (steps_seg+1)*step_spacing;
echo(" total length : ",total_length)
echo(" segment length : ",segment_length)

translate([0,0,total_length-1000]){

//all_segments();
//segment(5);
baseplate_detail(3,"down");
}

module baseplate_detail(i,side){
    z_delta = (i-1)*step_spacing*(steps_seg+1);
    x_delta = z_delta*tan(incline_deg);
    start_depth=start_depth+x_delta;
    adjacent = (step_spacing*(steps_seg))+piperadius*2;
    opp = adjacent * tan(incline_deg);    
    mid_x_delta = ((step_spacing*(steps_seg)+60)/2)*tan(incline_deg);
    if (side=="up"){
        translate([0,0,0])
        rotate([0,90,0]) baseplate("up",0,start_depth);
    }else if(side=="down"){    
        rotate([0,90,0]) baseplate("down",opp,start_depth);
    }else if (side=="right"){
        translate([0,0,0])
        rotate([0,90,0]) baseplate("midr",mid_x_delta,start_depth);
    }else if(side=="left"){
        translate([0,0,0])
        rotate([0,90,0]) baseplate("midl",mid_x_delta,start_depth);
    }    
}
module all_segments(){
    for (i = [1:1:num_segments]){
        segment(i);
    }
}

module segment(i){
    
    z_delta = (i-1)*step_spacing*(steps_seg+1);
    x_delta = z_delta*tan(incline_deg);
    start_depth=start_depth+x_delta;
    echo(start_depth);
    translate([0,0,-z_delta])    
    segment();
    module segment(){
    rail(steps_seg,step_spacing,"left",start_depth);
    translate([0,width,0])
    rail(steps_seg,step_spacing,"right",start_depth);
    
    for (i = [1:1:steps_seg+1]){
        z_delta = (i-1)*step_spacing;
        x_delta = z_delta*tan(incline_deg);
        //echo(round(x_delta));
        translate([x_delta,0,step_spacing*steps_seg-z_delta])
        step(start_depth);
    }
}
}
module step(start_depth){
    translate([start_depth-piperadius/2,width+piperadius,20+piperadius/2])
    rotate([90,0,0])
    cylinder(r=piperadius, h=width+piperadius*2);
}
module rail(steps,spacing,side,start_depth){
    adjacent = (step_spacing*(steps_seg))+piperadius*2;
    hyp = adjacent / cos(incline_deg);
    opp = adjacent * tan(incline_deg);
    //echo("  adjacent    : ", adjacent);
    //echo("  hypotenouse : ", hyp);
    //echo("  opposite : ", opp);
    translate([start_depth+20+opp,0,piperadius])
    rotate([0,-incline_deg,0])
    cylinder(r=piperadius, h=hyp);
    rotate([0,90,0]) baseplate("down",opp,start_depth);
    translate([0,0,step_spacing*(steps_seg)+60])
    rotate([0,90,0]) baseplate("up",0,start_depth);
    mid_x_delta = ((step_spacing*(steps_seg)+60)/2)*tan(incline_deg);
    if (side=="right"){
        translate([0,0,(step_spacing*(steps_seg)+60)/2])
        rotate([0,90,0]) baseplate("midr",mid_x_delta,start_depth);
    }else if(side=="left"){
        translate([0,0,(step_spacing*(steps_seg)+60)/2])
        rotate([0,90,0]) baseplate("midl",mid_x_delta,start_depth);
    }
    
}

module baseplate(type,depth,start_depth){
    if (type=="midr"){
        translate([-20,20,0]){
            baseplate();
            translate([0,0,3]) rotate([90,0,0]) armstrut();
        }
    } else if (type=="midl"){
        translate([-20,-20,0]){
            baseplate();
            translate([0,0,3]) rotate([90,0,0]) armstrut();
        }
    }else{
        baseplate();
        translate([0,0,3]) rotate([90,0,0]) armstrut();
    }
    module baseplate(){
        cylinder(r=piperadius, start_depth+depth+1);
    linear_extrude(height=platethickness){
        translate([30,0,0]){
            difference(){
                    roundedplate();
                    translate([baseplate_x/2-screwhole_offset,baseplate_y/2-screwhole_offset,0]) circle(screwhole_radius);
                    translate([baseplate_x/2-screwhole_offset,-
                    baseplate_y/2+screwhole_offset,0]) circle(screwhole_radius);
                    translate([-baseplate_x/2+screwhole_offset,baseplate_y/2-screwhole_offset,0]) circle(screwhole_radius);
                    translate([-baseplate_x/2+screwhole_offset,-baseplate_y/2+screwhole_offset,0]) circle(screwhole_radius);
                }
            }
        }
    }
    translate([0,0,depth])
    arc(20,type,start_depth);
    
}

module roundedplate(){
minkowski()
{
    square([baseplate_x,baseplate_y],center=true);
    circle(r = 10);
}
}

module arc(rad,type,start_depth){
    eps = 0.01;
    //echo(type);
    translate([eps-rad, 0, start_depth])
    if (type=="down"){
        rotate([90,0,0]) arc(90+incline_deg);
    } else if( type=="up"){
        translate([40,0,0])
        rotate([90,-90-incline_deg,0]) arc(90-incline_deg);
    } else if( type=="midr"){
        rotate([90,0,90]) arc(91);
    } else if( type=="midl"){
        rotate([90,0,-90]) arc(91);
    }
    module arc(angle){
       difference(){
       rotate_extrude(angle=angle, convexity=10)
           translate([rad, 0]) circle(piperadius);     
        
       rotate_extrude(angle=angle, convexity=10)
           translate([rad, 0]) circle(piperadius-(platethickness));     
        }        
    }
    
}

module armstrut(){
    points = [[15,0], [80,0], [15,110]];
    translate([0,0,-platethickness/2]) linear_extrude(height=platethickness){
    polygon(points=points);
    }
}