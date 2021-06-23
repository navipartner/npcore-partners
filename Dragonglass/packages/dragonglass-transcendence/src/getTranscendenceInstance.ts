import { TRANSCENDENCE_SCRIPT } from "./NaviPartner.Transcendence";
import { ITranscendence } from "./ITranscendence";

function getTranscendencePromise(dragonglass: any, window: any): Promise<ITranscendence> {
    const transcendenceFunc = new Function("dragonglass", "window", TRANSCENDENCE_SCRIPT);
    const transcendence = transcendenceFunc(dragonglass, window) as Promise<ITranscendence>;
    return transcendence as Promise<ITranscendence>;
}

export const getTranscendenceInstance = async (dragonglass: any, window: any): Promise<ITranscendence> => await getTranscendencePromise(dragonglass, window);
