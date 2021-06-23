/**
 * Returns prototype of async function. Must use evel!
 * 
 * Don't change this to:
 * 
 *      export const AsyncFunction = Object.getPrototypeOf(async function () { }).constructor;
 * 
 * If you do, Babel returns prototype of "function" rather than "async function"
 */
export const AsyncFunction = eval("Object.getPrototypeOf(async function () { }).constructor");
