import { IDataStateRow } from "./IDataStateRow";

export interface IDataStateSet extends Array<IDataStateRow> {
    _current: IDataStateRow | null;
    _count: number;
    _invalid: boolean;
}
