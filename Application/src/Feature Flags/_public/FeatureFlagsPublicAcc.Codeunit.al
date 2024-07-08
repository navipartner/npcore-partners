codeunit 6184675 "NPR Feature Flags Public Acc."
{
    procedure IsEnabled(FeatureFlagName: Text[50]): Boolean
    var
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        exit(FeatureFlagsManagement.IsEnabled(FeatureFlagName));
    end;


}