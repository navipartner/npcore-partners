page 6151265 "NPR POS Unit Rcpt.Text Profile"
{
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
                Caption = 'Genearl';
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Break Line"; Rec."Break Line")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the value of the Break Line field. Text set in a Sales Ticket Receipt field will be broken on each number of characters set in a Break Line field.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }

                field("Sales Ticket Rcpt. Text"; Rec."Sales Ticket Rcpt. Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket Receipt Text field.';
                    MultiLine = true;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
            }
            part(TicketRcptTextLines; "NPR POS Ticket Rcpt. Text")
            {
                ApplicationArea = All;
                Enabled = Rec.Code <> '';
                SubPageLink = "Rcpt. Txt. Profile Code" = FIELD(Code);
            }
        }
    }
}

