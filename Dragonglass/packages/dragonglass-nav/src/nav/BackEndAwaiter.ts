import { Delegate_T, PropertyBag } from "dragonglass-core";

class BackEndAwaiter {
  private _awaiters: PropertyBag<Delegate_T<any>> = {};

  public get awaiters(): PropertyBag<Delegate_T<any>> {
    return this.awaiters;
  }

  public async await<T>(id: string): Promise<T> {
    return new Promise<T>(resolve => this._awaiters[id] = resolve);
  }

  public resolveResponse(id: string, method: string, response: any): void {
    const awaiter = this._awaiters[id];
    if (!awaiter) {
      console.warn(`Back-end Method Invocation problem! An unexpected response received on method ${method}`);
      return;
    }
    delete this._awaiters[id];
    awaiter(response);
  }
}

export const BackEndMethodInvocationAwaiter = new BackEndAwaiter();
