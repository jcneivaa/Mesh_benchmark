import java.util.Map;

class Boid {
  Node node;
  int grabsMouseColor;
  int avatarColor;
  // fields
  Vector position, velocity, acceleration, alignment, cohesion, separation; // position, velocity, and acceleration in
  // a vector datatype
  float neighborhoodRadius; // radius in which it looks for fellow boids
  float maxSpeed = 4; // maximum magnitude for the velocity vector
  float maxSteerForce = .1f; // maximum magnitude of the steering vector
  float sc = 3; // scale factor for the render of the boid
  float flap = 0;
  float t = 0;


//Shalalalalalalalala
  HashMap<Integer,VertexList> vvrepresentation;
  HashMap<Integer,VertexList> fvrepresentation;
  ArrayList<Vector> vlist;// Shape vertex
  ArrayList<IntList> vvlist; //Lists for Vertex-Vertex representation
  ArrayList<IntList> fvlist; //Lists of faces surrounding a vertex
  ArrayList<IntList> flist; //List of vertex in a face
  PShape edge;
  PShape face;




//Shalalalalalalalala




  Boid(Vector inPos) {
    grabsMouseColor = color(0, 0, 255);
    avatarColor = color(255, 255, 0);
    position = new Vector();
    position.set(inPos);
//Start of representation    
    //Set of parameters for Vertex-Vertex representation
    vlist = new ArrayList<Vector>();
    vvlist = new ArrayList<IntList>();
    vvrepresentation = new HashMap<Integer,VertexList>();
    
    createVertex();
    createVVRepresentation();
    
    edge= createShape();
    edge= drawVVRetained();
    
    //Set of parameters for Face-Vertex Representation
    
    flist = new ArrayList<IntList>();
    fvlist = new ArrayList<IntList>();
    fvrepresentation = new HashMap<Integer,VertexList>();
    
    createFace();
    createFVRepresentation();
    
    face= createShape();
    face= drawFVRetained();
    
//End of representation    
    node = new Node(scene) {
      // Note that within visit() geometry is defined at the
      // node local coordinate system.
      @Override
      public void visit() {
        if (animate)
          run(flock);
        render();
      }

      // Behaviour: tapping over a boid will select the node as
      // the eye reference and perform an eye interpolation to it.
      @Override
      public void interact(TapEvent event) {
        if (avatar != this && scene.eye().reference() != this) {
          avatar = this;
          scene.eye().setReference(this);
          scene.interpolateTo(this);
        }
      }
    };
    node.setPosition(new Vector(position.x(), position.y(), position.z()));
    velocity = new Vector(random(-1, 1), random(-1, 1), random(1, -1));
    acceleration = new Vector(0, 0, 0);
    neighborhoodRadius = 100;
  }

  public void run(ArrayList<Boid> boids) {
    t += .1;
    flap = 10 * sin(t);
    // acceleration.add(steer(new Vector(mouseX,mouseY,300),true));
    // acceleration.add(new Vector(0,.05,0));
    if (avoidWalls) {
      acceleration.add(Vector.multiply(avoid(new Vector(position.x(), flockHeight, position.z())), 5));
      acceleration.add(Vector.multiply(avoid(new Vector(position.x(), 0, position.z())), 5));
      acceleration.add(Vector.multiply(avoid(new Vector(flockWidth, position.y(), position.z())), 5));
      acceleration.add(Vector.multiply(avoid(new Vector(0, position.y(), position.z())), 5));
      acceleration.add(Vector.multiply(avoid(new Vector(position.x(), position.y(), 0)), 5));
      acceleration.add(Vector.multiply(avoid(new Vector(position.x(), position.y(), flockDepth)), 5));
    }
    flock(boids);
    move();
    checkBounds();
  }

  Vector avoid(Vector target) {
    Vector steer = new Vector(); // creates vector for steering
    steer.set(Vector.subtract(position, target)); // steering vector points away from
    steer.multiply(1 / sq(Vector.distance(position, target)));
    return steer;
  }

  //-----------behaviors---------------

  void flock(ArrayList<Boid> boids) {
    //alignment
    alignment = new Vector(0, 0, 0);
    int alignmentCount = 0;
    //cohesion
    Vector posSum = new Vector();
    int cohesionCount = 0;
    //separation
    separation = new Vector(0, 0, 0);
    Vector repulse;
    for (int i = 0; i < boids.size(); i++) {
      Boid boid = boids.get(i);
      //alignment
      float distance = Vector.distance(position, boid.position);
      if (distance > 0 && distance <= neighborhoodRadius) {
        alignment.add(boid.velocity);
        alignmentCount++;
      }
      //cohesion
      float dist = dist(position.x(), position.y(), boid.position.x(), boid.position.y());
      if (dist > 0 && dist <= neighborhoodRadius) {
        posSum.add(boid.position);
        cohesionCount++;
      }
      //separation
      if (distance > 0 && distance <= neighborhoodRadius) {
        repulse = Vector.subtract(position, boid.position);
        repulse.normalize();
        repulse.divide(distance);
        separation.add(repulse);
      }
    }
    //alignment
    if (alignmentCount > 0) {
      alignment.divide((float) alignmentCount);
      alignment.limit(maxSteerForce);
    }
    //cohesion
    if (cohesionCount > 0)
      posSum.divide((float) cohesionCount);
    cohesion = Vector.subtract(posSum, position);
    cohesion.limit(maxSteerForce);

    acceleration.add(Vector.multiply(alignment, 1));
    acceleration.add(Vector.multiply(cohesion, 3));
    acceleration.add(Vector.multiply(separation, 1));
  }

  void move() {
    velocity.add(acceleration); // add acceleration to velocity
    velocity.limit(maxSpeed); // make sure the velocity vector magnitude does not
    // exceed maxSpeed
    position.add(velocity); // add velocity to position
    node.setPosition(position);
    node.setRotation(Quaternion.multiply(new Quaternion(new Vector(0, 1, 0), atan2(-velocity.z(), velocity.x())),
      new Quaternion(new Vector(0, 0, 1), asin(velocity.y() / velocity.magnitude()))));
    acceleration.multiply(0); // reset acceleration
  }

  void checkBounds() {
    if (position.x() > flockWidth)
      position.setX(0);
    if (position.x() < 0)
      position.setX(flockWidth);
    if (position.y() > flockHeight)
      position.setY(0);
    if (position.y() < 0)
      position.setY(flockHeight);
    if (position.z() > flockDepth)
      position.setZ(0);
    if (position.z() < 0)
      position.setZ(flockDepth);
  }

  void render() {
    pushStyle();

    // uncomment to draw boid axes
    //scene.drawAxes(10);


    //Draw boid
  if(representation==0){
   if(mode==0){
      drawVVImmediate();
   }else{
      shape(edge); 
   }
  }else{
   if(mode==0){
     drawFVImmediate();
   }else{
     shape(face); 
   }
  }

  //drawVVImmediate();
  //shape(edge); 
  
  //drawFVImmediate();
  //shape(face); 


    popStyle();

  }
  
  void createVertex(){
      vlist.add(new Vector(3 * sc, 0, 0));
      vlist.add(new Vector(-3 * sc, 2 * sc, 0));
      vlist.add(new Vector(-3 * sc, -2 * sc, 0));
      vlist.add(new Vector(-3 * sc, 0, 2 * sc));  
  }
  
  void createFace(){
     flist.add(new IntList(0,1,2));
     flist.add(new IntList(0,1,3));
     flist.add(new IntList(0,2,3));
     flist.add(new IntList(1,2,3));
  }
  
  void createVVList(){
     vvlist.add(new IntList(1,2,3));
     vvlist.add(new IntList(0,2,3));
     vvlist.add(new IntList(1,0,3));
     vvlist.add(new IntList(1,2,0));
  }
 
 void createFVList(){
     fvlist.add(new IntList(0,1,2));
     fvlist.add(new IntList(0,1,3));
     fvlist.add(new IntList(0,2,3));
     fvlist.add(new IntList(1,2,3));
 }
 
  void createVVRepresentation(){
     createVVList();
     for (int x=0;x<vlist.size();++x){
        vvrepresentation.put(x,new VertexList(vlist.get(x),vvlist.get(x))); 
     }
  }
  
  void createFVRepresentation(){
    createFVList();  
    for (int x=0;x<vlist.size();++x){
        fvrepresentation.put(x,new VertexList(vlist.get(x),fvlist.get(x))); 
    }
  }
  
  void drawVVImmediate(){
    stroke(color(0,128,175));
    fill(color(0,128,175)); 
    beginShape(LINES);
     for (int x=0;x<vlist.size();++x){
      Vector vaux = new Vector();
      IntList laux = new IntList();
      vaux = vvrepresentation.get(x).getVertex();
      laux = vvrepresentation.get(x).getList();
      
      for (int y=0;y<laux.size();++y){
       vertex(vaux.x(),vaux.y(),vaux.z());
       vertex(vvrepresentation.get(y).getVertex().x(),vvrepresentation.get(y).getVertex().y(),vvrepresentation.get(y).getVertex().z());
      }
      
     }
     
     endShape();
    
  }
  
  void drawFVImmediate(){
    stroke(color(0,128,175));
    fill(color(0,128,175)); 
    beginShape(TRIANGLES);
     for (int x=0;x<flist.size();++x){
       for(int y=0;y<3;++y){
         vertex(fvrepresentation.get(flist.get(x).get(y)).getVertex().x(),fvrepresentation.get(flist.get(x).get(y)).getVertex().y(),fvrepresentation.get(flist.get(x).get(y)).getVertex().z());
       }
      }
     
     
     endShape();
    
    
  }
  
  PShape drawVVRetained(){
      
    PShape aux;
    aux = createShape();
    aux.beginShape(LINES);
    aux.stroke(color(129,84,202));
    aux.fill(color(129,84,202));
     for (int x=0;x<vlist.size();++x){
      Vector vaux = new Vector();
      IntList laux = new IntList();
      vaux = vvrepresentation.get(x).getVertex();
      laux = vvrepresentation.get(x).getList();
      
      for (int y=0;y<laux.size();++y){

       aux.vertex(vaux.x(),vaux.y(),vaux.z());
       aux.vertex(vvrepresentation.get(y).getVertex().x(),vvrepresentation.get(y).getVertex().y(),vvrepresentation.get(y).getVertex().z());
      }


     }
     aux.endShape();     
     return aux;
  }
  
  PShape drawFVRetained(){
      
    PShape aux;
    aux = createShape();
    aux.beginShape(TRIANGLES);
    aux.stroke(color(129,84,202));
    aux.fill(color(129,84,202));
      for (int x=0;x<flist.size();++x){
       for(int y=0;y<3;++y){
         aux.vertex(fvrepresentation.get(flist.get(x).get(y)).getVertex().x(),fvrepresentation.get(flist.get(x).get(y)).getVertex().y(),fvrepresentation.get(flist.get(x).get(y)).getVertex().z());
       }
      }
     aux.endShape();     
     return aux;
  }
}