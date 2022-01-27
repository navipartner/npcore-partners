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

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Break Line"; Rec."Break Line")
                {

                    ToolTip = 'Specifies the value of the Break Line field. Text set in a Sales Ticket Receipt field will be broken on each number of characters set in a Break Line field.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }

                field("Sales Ticket Rcpt. Text"; Rec."Sales Ticket Rcpt. Text")
                {

                    ToolTip = 'Specifies the value of the Sales Ticket Receipt Text field.';
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

