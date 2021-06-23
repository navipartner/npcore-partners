import { FrontEndAsyncHandler } from "./FrontEndAsyncHandler";
import { BackEndMethodInvocationResult } from "./BackEndMethodInvocationResult";

export const FrontEndAsyncInterface = new FrontEndAsyncHandler();

// Default handlers
FrontEndAsyncInterface.register(new BackEndMethodInvocationResult(), "BackEndMethodInvocationResult");
