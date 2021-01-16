page 6150746 "NPR Unfinished POS Sale"
{
    // NPR5.54/ALPO/20200203 CASE 364658 Resume POS Sale

    Caption = 'Unfinished POS Sale';
    Editable = false;
    InstructionalText = 'There is an unfinished sale, do you want to resume it?';
    PageType = ConfirmationDialog;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Sale POS";

    layout
    {
        area(content)
        {
            field(Control6014409; '')
            {
                ApplicationArea = All;
                CaptionClass = Format(GenerateInstructions());
                MultiLine = true;
                ShowCaption = false;
                ToolTip = 'Specifies the value of the '''' field';
            }
            group(Details)
            {
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Register No. field';
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("Date"; Date)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date field';
                }
                field("Start Time"; "Start Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Start Time field';
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field("Customer Name"; "Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Name field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';

                    trigger OnDrillDown()
                    begin
                        DrillDownDocument;
                    end;
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Including VAT field';

                    trigger OnDrillDown()
                    begin
                        DrillDownDocument;
                    end;
                }
                field("Payment Amount"; "Payment Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Amount field';

                    trigger OnDrillDown()
                    begin
                        DrillDownDocument;
                    end;
                }
            }
        }
    }

    actions
    {
    }

    var
        LeaveAsIsAndNewText: Label 'Note: Selecting ''No'' will start a new sale leaving the unfinished sale untouched.';
        CancelAndNewText: Label 'Note: If you select ''No'', system will try to cancel the sale.';
        AllowToPostpone: Boolean;

    local procedure GenerateInstructions(): Text
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
        UnfinishedPOSSaleTransact.RunModal;
    end;
}

