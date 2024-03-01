page 6151495 "NPR Vipps Mp UserPass"
{
    PageType = Card;
    Caption = 'OnPrem Additional Setup';
    Extensible = false;
    UsageCategory = None;
    SourceTable = "NPR Vipps Mp UserPass";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            field(FriendlyNameId; Rec.FriendlyNameId)
            {
                Enabled = EditableName;
                ToolTip = 'Specifies name used in the external config, use something easy to spot, like [company-name]-msn';
                ApplicationArea = NPRRetail;
#if NOT BC17
                AboutTitle = 'Config Name';
                AboutText = 'Specifies name used in the external config, use something easy to spot, like [company-name]-msn';
#endif
            }
            field(Username; Rec.Username)
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the username of the user that is able to send webhooks.';
#if NOT BC17
                AboutTitle = 'Username';
                AboutText = 'Specifies the username of the user that is able to send webhooks.';
#endif
            }
            field(Password; Rec.Password)
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the password of the user that is able to send webhooks.';
#if NOT BC17
                AboutTitle = 'Password';
                AboutText = 'Specifies the password of the user that is able to send webhooks.';
#endif
            }

        }
    }
    trigger OnOpenPage()
    begin
        EditableName := Rec.FriendlyNameId = '';
    end;

    var
        EditableName: Boolean;
}