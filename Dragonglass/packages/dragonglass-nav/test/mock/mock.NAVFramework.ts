import { Delegate_T } from "dragonglass-core";
import { INAVEnvironment } from "../../src/nav/INAVEnvironment";
import { INAVFramework } from "../../src/nav/INAVFramework";

interface MockNAVEnvironment extends INAVEnvironment {
    _setBusy: Delegate_T<boolean>,
    _awaiters: Function[],
    _await: Delegate_T<Function>;
};

export const MOCK_NAV_THROW_ERROR = Symbol();

export const mockNAVEnvironment = () => {
    const env = {
        Busy: false,
        OnBusyChanged: () => { },
        _setBusy: (busy: boolean) => {
            const changed = busy !== env.Busy;
            if (!changed)
                return;

            env.Busy = busy;
            env.OnBusyChanged(busy);

            if (env._awaiters) {
                env._awaiters.forEach(a => a());
                env._awaiters = [];
            }

        },
        _awaiters: [],
        _await: func => env._awaiters.push(func),
    } as MockNAVEnvironment;

    return env;
};

interface MockNAVFramework extends INAVFramework {
    _env: MockNAVEnvironment,
    _autoBusy: boolean;
};

export const mockNAVFramework = (descriptor: any = {}) => {
    const framework = {
        _env: mockNAVEnvironment(),
        GetEnvironment: () => (framework as any)._env,
        GetImageResource: jest.fn().mockImplementation(path => path),
        InvokeExtensibilityMethod: jest.fn().mockImplementation((event: string, args: any[], skipIfBusy: boolean, callback: Function) => {
            if (args?.includes(MOCK_NAV_THROW_ERROR))
                throw new Error("NAV threw an error, what do you know...");
                
            const call = () => {
                framework._env._setBusy(true);
                setTimeout(() => {
                    callback();
                    framework._env._setBusy(false);
                }, 15); // Mimicking a 15ms network latency
            };

            if (skipIfBusy && framework._env.Busy)
                return;

            
            if (framework._env.Busy) {
                framework._env._await(framework._autoBusy ? call : callback);
                return;
            }

            if (framework._autoBusy)
                call();
            else
                callback();
        }),
        _autoBusy: true,
        ...descriptor
    } as MockNAVFramework;

    return framework;
};
