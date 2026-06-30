codeunit 6151098 "NPR Web Post Date Check"
{
    Access = Internal;

    var
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
        WebOrderAutoCorrectPostingDateFlagTok: Label 'webOrdersCorrectPostingDate', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header")
    begin
        WarnIfPostingDateNotWorkDate(SalesHeader);
    end;

    internal procedure UpdatePostingDateIfWebOrder(var SalesHeader: Record "Sales Header")
    var
        WebPostCurrSuppress: Codeunit "NPR Web Post Curr. Suppress";
    begin
        if SalesHeader."Posting Date" = WorkDate() then
            exit;
        if not FeatureFlagsManagement.IsEnabled(WebOrderAutoCorrectPostingDateFlagTok) then
            exit;

        SalesHeader.SetHideValidationDialog(true);
        BindSubscription(WebPostCurrSuppress);
        SalesHeader.Validate("Posting Date", WorkDate());
        UnbindSubscription(WebPostCurrSuppress);
        SalesHeader.Modify(true);
        Commit();
    end;

    local procedure WarnIfPostingDateNotWorkDate(SalesHeader: Record "Sales Header")
    begin
        if not FeatureFlagsManagement.IsEnabled(WebOrderAutoCorrectPostingDateFlagTok) then
            exit;
        SalesHeader.TestPostingDate(false);
    end;
}
