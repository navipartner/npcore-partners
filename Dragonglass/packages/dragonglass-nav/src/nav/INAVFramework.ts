import { INAVEnvironment } from "./INAVEnvironment";

export interface INAVFramework {
    GetImageResource(key: string): string;
    GetEnvironment(): INAVEnvironment;
    InvokeExtensibilityMethod(name: string, args: any[], skipIfBusy: boolean, callback: Function): void;
}
