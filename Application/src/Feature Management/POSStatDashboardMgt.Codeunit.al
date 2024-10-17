codeunit 6150657 "NPR POS Stat Dashboard Mgt"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', true, true)]
    local procedure OnRequestPOSStatDashboardFeatureEnabled(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        ResponseObject: JsonObject;
    begin
        if Method = 'PosStatDashFeature_GetEnabled' then begin
            Handled := true;
            ResponseObject.Add('POSStatDashboardFeatureEnabled', IsPOSStatDashboardFeatureEnabled());
            FrontEnd.RespondToFrontEndMethod(Context, ResponseObject, FrontEnd);
        end;
    end;

    local procedure IsPOSStatDashboardFeatureEnabled(): Boolean
    var
        FeatureRecord: Record "NPR Feature";
    begin
        FeatureRecord.SetRange(Feature, FeatureRecord.Feature::"POS Statistics Dashboard");

        if FeatureRecord.FindFirst() then
            exit(FeatureRecord.Enabled)
        else
            exit(false);
    end;
}