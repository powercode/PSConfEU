namespace DotNet {
    public class Person {
        public Person(){}
        public Person(string name, int age){
            Name = name;
            Age = age;
        }
        public string Name {get;set;}
        public int Age {get;set;}

        public override string ToString() {
            return Name;
        }
    }
}