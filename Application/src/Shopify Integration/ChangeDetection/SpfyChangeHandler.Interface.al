interface "NPR Spfy Change Handler"
{
    Access = Internal;

    /// <summary>Returns true if at least one NC task was created.</summary>
    procedure ProcessChange(var DetectedChange: Codeunit "NPR Spfy Detected Change"): Boolean;
}
