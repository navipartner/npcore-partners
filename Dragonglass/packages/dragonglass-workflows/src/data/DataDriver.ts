import { DataSource } from "./DataSource";

export interface DataDriver<T> {
    reset(): void;
    hasMoreData(): Promise<boolean>;
    fetchNextBatch(batchSize: number): Promise<T[]>;
}
