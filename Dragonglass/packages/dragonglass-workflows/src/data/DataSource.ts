import { Delegate_T } from "dragonglass-core";
import { DataDriver } from "./DataDriver";

const DEFAULT_BATCH_SIZE = 50;

export class DataSource<T> {
    private _loadAll: boolean = false;
    private _batchSize: number = DEFAULT_BATCH_SIZE;
    private _driver: DataDriver<T>;
    private _cache: T[];

    constructor(driver: DataDriver<T>) {
        this._driver = driver;
        this._cache = [];
    }

    get loadAll(): boolean {
        return this._loadAll;
    }

    set loadAll(value: boolean) {
        this._loadAll = value;
    }

    get batchSize(): number {
        return this._batchSize;
    }

    set batchSize(value: number) {
        this._batchSize = value;
    }

    public async fetch(onFetch: Delegate_T<T[]>): Promise<boolean> {
        const data: T[] = await this._driver.fetchNextBatch(this._batchSize);
        if (!data.length) {
            return false;
        }

        this._cache = this._cache.concat(data)
        onFetch(this._cache);
        
        return await this._driver.hasMoreData();
    }
}
