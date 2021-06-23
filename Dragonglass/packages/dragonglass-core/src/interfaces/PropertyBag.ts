/**
 * Represents an object that can be expanded through dynamic properties where each property
 * has a value of the same type known up-front. This interface exists to avoid randomly
 * declaring variables of any type.
 * 
 * This makes expanding objects more intentional and explicit in situation where objects
 * are used as "property bags" of some type.
 * 
 * For example:
 * 
 *      const a: PropertyBag<string> = {};
 *      a.foo = "bar";
 * 
 * ... is better than
 * 
 *      const b: any = {};
 *      b.foo = "bar";
 * 
 * The second version makes object implicitly expandable which can lead to bugs. The
 * first version makes it explicitly expandable which expresses developer's intention
 * for it to be that way.
 */
export interface PropertyBag<T> {
    [key: string]: T
}
