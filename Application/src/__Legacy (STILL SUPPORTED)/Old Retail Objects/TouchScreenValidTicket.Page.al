page 6014584 "NPR TouchScreen: Valid. Ticket"
{
    // NPR70.00.00.00/TS/20141223 CASE 202667 Page Created

    UsageCategory = None;
    Caption = 'Touch Screen - Validate Ticket';

    layout
    {
        area(content)
        {
            field(Control6150618; '')
            {
                ApplicationArea = All;
                Caption = 'Scan Ticket';
                HideValue = true;
                Style = Strong;
                StyleExpr = TRUE;
                ToolTip = 'Specifies the value of the Scan Ticket field';
            }
            field(Input; Validering)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Validering field';

                trigger OnValidate()
                begin
                    ValidateTicket(Validering);
                end;
            }
            field(TextMessage; MessageText)
            {
                ApplicationArea = All;
                Editable = false;
                MultiLine = true;
                ToolTip = 'Specifies the value of the MessageText field';
            }
        }
    }

    actions
    {
        area(creation)
        {
            action(Close)
            {
                Caption = 'Close';
                Ellipsis = true;
                Image = Close;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Close action';

                trigger OnAction()
                begin

                    if Validering <> '' then begin
                        Validering := '<CANCEL>';
                        exit;
                    end;
                    Validering := '<CANCEL>';
                    CurrPage.Close;
                end;
            }
        }
    }

    var
        TicketMgt: Codeunit "NPR TM Ticket Management";
        MessageText: Text[100];
        Title: Text[250];
        Validering: Text[250];
        FontColor: Option Normal,Red,Green;
        TextAllreadyUsed: Label 'The ticket has allready been used.';
        TextTicketApproved: Label 'The ticket has been approved.';
        TextTicketNotFound: Label 'The ticket was not found.';
        Close: Text;

    procedure GetValidering(): Code[50]
    begin
        // GetValidering
        exit(Validering);
    end;

    procedure Init(TitleIn: Text[250])
    begin
        // Init
        Title := TitleIn;
    end;

    procedure ValidateTicket(TicketBarCode: Code[20])
    var
        Ticket: Record "NPR TM Ticket";
    begin
        Ticket.SetRange("No.", TicketBarCode);
        if not Ticket.FindFirst then begin
            Clear(Ticket);
            Ticket.SetCurrentKey("Ticket No. for Printing");
            Ticket.SetRange("Ticket No. for Printing", TicketBarCode);
        end;

        if Ticket.FindFirst then begin
            if not Ticket.Blocked then begin
                FontColor := FontColor::Green;
                MessageText := TextTicketApproved;
                Ticket.Blocked := true;
                Ticket.Modify;
            end else begin
                FontColor := FontColor::Red;
                MessageText := TextAllreadyUsed;
            end
        end else begin
            FontColor := FontColor::Red;
            MessageText := TextTicketNotFound;
        end;
    end;
}

