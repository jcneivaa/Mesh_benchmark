public class VertexList{
 
  Vector vertex;
  IntList list;
  
  public Vector getVertex(){
   return vertex;
  }
  
  public void setVertex(Vector vertex){
    this.vertex = vertex;
  }
  
  public IntList getList(){
   return list; 
  }
  
  public void setList(IntList list){
   this.list = list; 
  }
  
  public VertexList(){
   this.vertex=null; 
    this.list=null;
  }
  
  public VertexList(Vector vertex, IntList list){
    this.vertex = vertex;
    this.list = list;
  }
  
  
}