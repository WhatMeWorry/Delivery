

| Class  | unit of object encapsulation |
| ------ | ------ |
| cookie cutter for creating objects. Like jig, template, or blueprint. |
| specific instances of classes are called objects |
| objects are created through the use of the keyword __new__ |
| they consist of: |
| 1) constants |
| 2) state/data/fields per-object by default, per-class with use of __static__ modifier |
| 3) methods/operations per-object by default, per-class with use of __static__ modifier |
|    |
| accessed with . (dot)  So object.someDataOrMethod for both per-object and per-class state and methods |
| static class state/methods can also be accessed even if no objects exist through the class.someDataOrMethod syntax | 
| Objects are accessed via references. |
| references are linked to class objects. this reference is also called _bindings_  |
| Objects may only be accessed through the use of references |
| One or more references may be bound to an object.  |
| Objects that have no references is an error called memory leak |
| A reference may exist without an object but it should be set to null.  |
| References that are not null and not bound to any object is an error called dangling pointer |
| Objects once created will reside in the same place in memory forever until Garbage Collected |
| using __object = new SomeClass__ creates a default initialized object. All fields use .init property |
| Customized constructors may be defined with a method named __this__ with no return type  |
| 
| this() {}  // default constructor  


