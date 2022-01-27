page 6150746 "NPR Unfinished POS Sale"
{
    Extensible = False;
    Caption = 'Unfinished POS Sale';
    Editable = false;
    InstructionalText = 'There is an unfinished sale, do you want to resume it?';
    PageType = ConfirmationDialog;
    UsageCategory = None;
    SourceTable = "NPR POS Sale";

    layout
    {
        area(content)
        {
            label(AddInstructionLbl)
            {
                ApplicationArea = NPRRetail;
                CaptionClass = GenerateInstructions();
                MultiLine = true;
                ShowCaption = false;
            }
            group(Details)
            {
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Ticket No."; Rec."Sales Ticket No.")
                {

                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    ToolTip = 'Specifies the value of the Salesperson Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Date"; Rec.Date)
                {

                    ToolTip = 'Specifies the value of the Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Start Time"; Rec."Start Time")
                {

                    ToolTip = 'Specifies the value of the Start Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer No."; Rec."Customer No.")
                {

                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Name"; Rec."Customer Name")
                {

                    ToolTip = 'Specifies the value of the Customer Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Amount; Rec.Amount)
                {

                    ToolTip = 'Specifies the value of the Amount field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        DrillDownDocument();
                    end;
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {

                    ToolTip = 'Specifies the value of the Amount Including VAT field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        DrillDownDocument();
                    end;
                }
                field("Payment Amount"; Rec."Payment Amount")
                {

                    ToolTip = 'Specifies the value of the Payment Amount field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        DrillDownDocument();
                    end;
                }
            }
        }
    }

    var
        LeaveAsIsAndNewText: Label 'Note: Selecting ''No'' will start a new sale leaving the unfinished sale untouched.';
        CancelAndNewText: Label 'Note: If you select ''No'', system will try to cancel the sale.';
        AllowToPostpone: Boolean;

# pragma warning disable AA0228
    local procedure GenerateInstructions(): Text
# pragma warning restore
    begin
        if AllowToPostpone then
            exit(LeaveAsIsAndNewText)
        else
            exit(CancelAndNewText);
    end;

    procedure SetAllowToPostpone(Set: Boolean)
    begin
        AllowToPostpone := Set;
    end;

    local procedure DrillDownDocument()
    var
        UnfinishedPOSSaleTransact: Page "NPR Unfinished POS Sale Trx";
    begin
        Clear(UnfinishedPOSSaleTransact);
        UnfinishedPOSSaleTransact.SetRecord(Rec);
        UnfinishedPOSSaleTransact.SetTableView(Rec);
        UnfinishedPOSSaleTransact.RunModal();
    end;
}
