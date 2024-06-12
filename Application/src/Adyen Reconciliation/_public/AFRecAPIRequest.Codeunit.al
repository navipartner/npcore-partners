codeunit 6184771 "NPR AF Rec. API Request"
{
    Access = Public;

    procedure ReceiveWebhook(json: Text): Text
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
        SuccessLbl: Label 'Successfully Imported.';
        ErrorLbl: Label 'Error Occured.';
    begin
        if AdyenManagement.ImportWebhook(json) then
            exit(SuccessLbl)
        else
            exit(ErrorLbl);
    end;

    [Obsolete('Use ProcessReportReadyWebhook(AdyenWebhook: Record "NPR Adyen Webhook") instead.', 'NPR35.0')]
    procedure PostReportReady(statusCode: Text; statusDescription: Text; headersCollection: Text; content: Text; webhookReference: Text): Text
    var
        ObsoleteProcedureLbl: Label 'Procedure PostReportReady is Obsolete. Use ProcessReportReadyWebhook(AdyenWebhook: Record "NPR Adyen Webhook") instead.';
    begin
        Error(ObsoleteProcedureLbl);
    end;
}
