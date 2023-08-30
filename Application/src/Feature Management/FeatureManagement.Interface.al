interface "NPR Feature Management"
{
#if not BC17
    Access = Internal;
#endif

    procedure AddFeature()
    procedure IsFeatureEnabled(): Boolean
    procedure SetFeatureEnabled(NewEnabled: Boolean)
}