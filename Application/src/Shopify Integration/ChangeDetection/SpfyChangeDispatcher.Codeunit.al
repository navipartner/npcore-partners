codeunit 6151187 "NPR Spfy Change Dispatcher"
{
    Access = Internal;

    procedure Dispatch(var DetectedChange: Codeunit "NPR Spfy Detected Change"): Boolean
    var
        Handler: Interface "NPR Spfy Change Handler";
    begin
        Handler := DetectedChange.IntegrationArea();
        exit(Handler.ProcessChange(DetectedChange));
    end;
}
