interface "NPR NationalIdentifierIface"
{
    /// <summary>
    /// Returns a short display name for the identifier type (for UI/help).
    /// </summary>
    procedure DisplayName(): Text;

    /// <summary>
    /// Returns an example of acceptable input format(s), e.g. 'YYYYMMDD-NNNN'.
    /// Keep it short; callers can show it when parsing fails.
    /// </summary>
    procedure ExpectedInputExample(): Text;

    /// <summary>
    /// Try to parse and validate user input and return a canonical representation suitable for storage/comparison.
    /// Canonical is whatever you standardize on (often digits-only).
    /// </summary>
    /// <param name="Input">Raw input (may contain spaces, hyphens, prefixes).</param>
    /// <param name="Canonical">Canonical value for storage if valid (e.g., digits-only).</param>
    /// <param name="ErrorMessage">Human friendly-ish message if invalid.</param>
    /// <returns>True if valid and Canonical is set; otherwise false.</returns>
    procedure TryParse(Input: Text; var Canonical: Text[30]; var ErrorMessage: Text): Boolean;

    /// <summary>
    /// Converts a canonical value into a user friendly display format.
    /// If Canonical is invalid/empty, return empty or a best-effort representation.
    /// </summary>
    procedure ShowUnMasked(Canonical: Text[30]): Text[30];

    /// <summary>
    /// Converts a canonical value into a user friendly masked display format.
    /// If Canonical is invalid/empty, return empty or a best-effort representation.
    /// </summary>
    procedure ShowMasked(Canonical: Text[30]): Text[30];

}