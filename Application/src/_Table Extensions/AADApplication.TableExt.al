tableextension 6014525 "NPR AAD Application" extends "AAD Application"
{
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
