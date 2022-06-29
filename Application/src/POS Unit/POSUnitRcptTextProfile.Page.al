page 6151265 "NPR POS Unit Rcpt.Text Profile"
{
    Extensible = False;
    Caption = 'POS Unit Receipt Text Profile';
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
                field("Break Line"; Rec."Break Line")
                {

                    ToolTip = 'Specifies the number of characters after which the line will break. The text set in a Sales Ticket Receipt field will be broken on each number of characters set in a Break Line field.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }

                field("Sales Ticket Rcpt. Text"; Rec."Sales Ticket Rcpt. Text")
                {

                    ToolTip = 'Specifies the text which will be displayed in the footer.';
                    MultiLine = true;
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
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

