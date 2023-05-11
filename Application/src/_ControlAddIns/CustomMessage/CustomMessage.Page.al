page 6059903 "NPR Custom Message Page"
{
    Extensible = False;
    PageType = Card;
    UsageCategory = None;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'Message';
    layout
    {
        area(Content)
        {
            usercontrol("Message Page"; "NPR Custom Message")
            {
                ApplicationArea = NPRRetail;

                trigger Ready()
                begin
                    CurrPage."Message Page".Init(_title, _message);
                    EmitTelemetry('Init Page');
                end;

                trigger OKCliked()
                begin
                    EmitTelemetry('Close(OkClicked)');
                    CurrPage.Close();
                end;
            }
        }
    }

    procedure ShowMessage(Title: Text; Message: Text)
    begin
        _title := Title;
        _message := Message;
        EmitTelemetry('Open');
        CurrPage.RunModal();
    end;

    procedure EmitTelemetry(Message: Text)
    var
        CustomDimensions: Dictionary of [Text, Text];
        ActiveSession: Record "Active Session";
    begin
        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        Session.LogMessage('CtrlAddin_CustomMessage', Message, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;

    var
        _title: Text;
        _message: Text;

}