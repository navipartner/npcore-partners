interface "NPR Spfy Task Send Boundary"
{
    Access = Internal;

    // Never raises for a dispatch outcome: a failure returns false with ErrorText set, so the engine always sweeps.
    procedure Dispatch(var SpfyTaskWork: Record "NPR Spfy Task"; var ErrorText: Text): Boolean;
}
