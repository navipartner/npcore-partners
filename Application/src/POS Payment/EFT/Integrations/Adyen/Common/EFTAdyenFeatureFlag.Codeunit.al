codeunit 6184644 "NPR EFT Adyen Feature Flag"
{
    // used to deploy new adyen cloud integration without .net and with page background tasks instead of background sessions, 
    // on top of existing customers onprem using it, with an option for rolling back in case of issues.

    // TODO: Delete in later release

    Access = Internal;

    procedure IsEnabled(): Boolean
    var
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        exit(FeatureFlagsManagement.IsEnabled('adyencloudwithoutdotnet_v2'));
    end;


}