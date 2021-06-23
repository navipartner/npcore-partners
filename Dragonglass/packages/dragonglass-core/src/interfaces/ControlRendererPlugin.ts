import { ControlRenderer } from "./ControlRenderer";

export interface ControlRendererPlugin {
    [key: string]: ControlRenderer
}