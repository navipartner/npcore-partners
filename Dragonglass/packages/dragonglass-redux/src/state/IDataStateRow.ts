import { PropertyBag } from "dragonglass-core";

export interface IDataStateRow extends PropertyBag<any> {
    _current: boolean;
    _deleted: boolean;
}
