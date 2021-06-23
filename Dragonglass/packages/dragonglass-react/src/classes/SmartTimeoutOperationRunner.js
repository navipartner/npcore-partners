import { GlobalErrorDispatcher } from "dragonglass-core";

/**
 * Allows running of async operations that can time out after a dynamic period. Running such operations guarantees that
 * the async operation (promise) will fulfill either after the async operation completes, or after dynamic timeout,
 * whichever occurs first.
 * The timeout is calculated dynamically over previous five operations, so it is adjusted in a way that makes sure that
 * enough time out period is left for operations to complete normally, but making sure timeout occurs if something goes
 * wrong.
 *
 * @export
 * @class SmartTimeoutOperationRunner
 */
export class SmartTimeoutOperationRunner {
    /**
     * Instantiates an instance.
     * @param {number} [graceTimeout=1000] Grace period to allow each operation to timeout. This will be added on top of dynamic timeout.
     * @memberof SmartTimeoutOperationRunner
     */
    constructor(graceTimeout = 5000) {
        this._graceTimeout = graceTimeout;
        this._durations = [];
        this._durations = [];
    }

    /**
     * Calculates the next timeout period based on data from previous runs.
     *
     * @returns Timeout in milliseconds
     * @memberof SmartTimeoutOperationRunner
     */
    _getNextTimeoutDuration() {
        return (this._durations.length
            ? (this._durations.reduce((prev, current) => prev + current, 0) / this._durations.length +
                Math.max(this._graceTimeout, this._durations.reduce((prev, current) => Math.max(prev, current), 0) / this._durations.length))
            : this._graceTimeout);
    }

    /**
     * (Internal, do not call) Sets up the timeout for the operation, and makes sure to resolve the promise when timeout occurs.
     * It returns a finalizer function that can be called when the main asynchronous operation completes. This finalizer function
     * resolves the promise if it wasn't already resolved.
     *
     * @param {*} fulfill Fulfill function of the main promise.
     * @returns Finalizer function
     * @memberof SmartTimeoutOperationRunner
     */
    _getOperationTimedOutFinalizer(fulfill) {
        let timedOut = false;
        const timeoutDuration = this._getNextTimeoutDuration();
        console.log("Next timeout: " + timeoutDuration);
        const complete = () => {
            if (timedOut)
                return;
            fulfill();
        };

        const awaitTimeout = setTimeout(
            () => {
                complete();
                timedOut = true;
            },
            timeoutDuration);

        return () => {
            clearTimeout(awaitTimeout);
            complete();
        };
    }

    /**
     * Runs the operation asynchronously and measures the time it took to perform the operation.
     *
     * @param {AsyncFunction} task Asynchronous operation to perform.
     * @memberof SmartTimeoutOperationRunner
     */
    async _runOperationWithTimeMeasurement(task) {
        const startTimestamp = Date.now();
        try {
            await task();
        }
        catch (e) {
            GlobalErrorDispatcher.raiseCriticalError(e);
        }
        finally {
            if (this._durations.length === 5)
                this._durations.shift();
            this._durations.push(Date.now() - startTimestamp);
        }
    }

    /**
     * Runs a timed-out operation asynchronously. This operation will complete either when time out occurs, or when the asynchronous operation completes
     * (whichever comes first).
     *
     * @param {AsyncFunction} task Task to run asynchronously
     * @returns Promise
     * @memberof SmartTimeoutOperationRunner
     */
    start(task) {
        return new Promise(async fulfill => {
            const finalize = this._getOperationTimedOutFinalizer(fulfill);
            await this._runOperationWithTimeMeasurement(task);
            finalize();
        });
    }
}