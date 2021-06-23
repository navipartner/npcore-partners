import { ArrayDataDriver } from "./ArrayDataDriver";
import { DataDriver } from "./DataDriver";
import { DataSource } from "./DataSource";

export class DataManager {
    public createArrayDriver<T>(array: T[]): DataDriver<T> {
        return new ArrayDataDriver<T>(array);
    }

    public createDataSource<T>(driver: DataDriver<T>) {
        return new DataSource<T>(driver);        
    }
}
