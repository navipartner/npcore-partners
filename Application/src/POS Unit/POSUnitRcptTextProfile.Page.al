page 6151265 "NPR POS Unit Rcpt.Text Profile"
{
    Extensible = False;
    Caption = 'POS Unit Receipt Text Profile';
    ContextSensitiveHelpPage = 'docs/retail/pos_profiles/reference/unit_receipt_profile_ref/unit_receipt_profile_ref/';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR POS Unit Rcpt.Txt Profile";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the unique code for a profile.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the short description of a profile.';
                    ApplicationArea = NPRRetail;
                }
            }
            part(TicketRcptTextLines; "NPR POS Ticket Rcpt. Text")
            {

                Enabled = Rec.Code <> '';
                SubPageLink = "Rcpt. Txt. Profile Code" = FIELD(Code);
                ApplicationArea = NPRRetail;
            }
        }
    }
}

