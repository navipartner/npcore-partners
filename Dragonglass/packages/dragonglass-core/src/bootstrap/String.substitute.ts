/**
 * Monkey-patches the String prototype with "substitute" function. This function allows AL developers writing
 * workflow code to create AL-like string substitutions:
 * 
 *      'Document %1 %2 is in status %3'.substitute('SI0132', 'Open');
 *      // => 'Document Invoice SI0132 is in status Open')
 */
export const bootstrapStringSubstituteMonkeyPatch = () => {
    Object.defineProperty(String.prototype,
        "substitute",
        {
            value: function (): string {
                let str = this as string, i = 0;
                [].slice.call(arguments).forEach(substring => str = str.replace(new RegExp("%" + ++i), substring));
                return str;
            }
        }
    );
}
