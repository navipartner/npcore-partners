tableextension 6014525 "NPR AAD Application" extends "AAD Application"
{
    fields
    {
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
        field(6014400; "NPR NP API Key Id"; Guid)
        {
            Caption = 'NaviPartner API Key Id';
            Editable = false;
            TableRelation = "NPR NP API Key";
            ToolTip = 'Specifies a link with NaviPartner API Key.';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2025-10-13';
            ObsoleteReason = 'Replaced by new field "NPR NaviPartner API Key Id" pointing to a new table created with `DataPerCompany = false`.';
        }
        field(6014401; "NPR NaviPartner API Key Id"; Guid)
        {
            Caption = 'NaviPartner API Key Id';
            Editable = false;
            TableRelation = "NPR NaviPartner API Key";
            ToolTip = 'Specifies a link with NaviPartner API Key.';
            DataClassification = CustomerContent;
        }
#endif
    }

    keys
    {
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
        key(NPRNPAPIKey; "NPR NaviPartner API Key Id")
        {
        }
#endif
    }

    trigger OnBeforeDelete()
    var
        AccessControl: Record "Access Control";
        ExternalJQRefresherMgt: Codeunit "NPR External JQ Refresher Mgt.";
        HttpResponseMessage: HttpResponseMessage;
        ResponseText: Text;
        CouldNotDeleteEntraAppLbl: Label 'The Entra application could not be removed because it is associated with the external job queue refresher, and updating the Entra app association database for the external job queue refresher has failed. Please contact system vendor to resolve this issue.\External response:\%1';
    begin
        AccessControl.SetRange("User Security ID", Rec."User ID");
        AccessControl.SetRange("Role ID", ExternalJQRefresherMgt.ExtJQRefresherRoleID());
        AccessControl.SetRange("App ID", Rec."App ID");
        if not AccessControl.IsEmpty() then begin
            ExternalJQRefresherMgt.ManageJQRefresherUser(Rec."Client Id", '', Enum::"NPR Ext. JQ Refresher Options"::delete, HttpResponseMessage);
            if not HttpResponseMessage.IsSuccessStatusCode() then begin
                HttpResponseMessage.Content().ReadAs(ResponseText);
                Error(CouldNotDeleteEntraAppLbl, ResponseText);
            end;
        end;
    end;
}
