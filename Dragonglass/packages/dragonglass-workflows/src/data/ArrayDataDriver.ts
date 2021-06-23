import { DataDriver } from "./DataDriver";

export class ArrayDataDriver<T> implements DataDriver<T> {
    private _array: T[];
    private _index: number = 0;

    constructor(array: T[]) {
        this._array = array;
    }

    public reset() {
        this._index = 0;
    }

    public replaceArray(array: T[]) {
        this._array = array;
        this._index = 0;
    }

    public async hasMoreData(): Promise<boolean> {
        return this._index < this._array.length;
    }

    public async fetchNextBatch(batchSize: number): Promise<T[]> {
        let result;

        if (!batchSize) {
            result = this._array.slice(this._index);
            this._index = this._array.length;
            return result;
        }

        const end = this._index + batchSize;
        result = this._array.slice(this._index, end);
        this._index = Math.min(end, this._array.length);

        return result;
    }
}
