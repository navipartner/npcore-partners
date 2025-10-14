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

    trigger OnDelete()
    var
        AccessControl: Record "Access Control";
        ExternalJQRefresherMgt: Codeunit "NPR External JQ Refresher Mgt.";
        HttpResponseMessage: HttpResponseMessage;
        ResponseText: Text;
    begin
        if AccessControl.Get(Rec."User ID", ExternalJQRefresherMgt.ExtJQRefresherRoleID(), '', AccessControl.Scope::System, Rec."App ID") then begin
            ExternalJQRefresherMgt.ManageJQRefresherUser(Rec."Client Id", '', Enum::"NPR Ext. JQ Refresher Options"::delete, HttpResponseMessage);
            if not HttpResponseMessage.IsSuccessStatusCode() then begin
                HttpResponseMessage.Content().ReadAs(ResponseText);
                Message(ResponseText);
                exit;
            end;
        end;
    end;
}
