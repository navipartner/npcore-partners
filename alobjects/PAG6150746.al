page 6150746 "Unfinished POS Sale"
{
    // NPR5.54/ALPO/20200203 CASE 364658 Resume POS Sale

    Caption = 'Unfinished POS Sale';
    Editable = false;
    InstructionalText = 'There is an unfinished sale, do you want to resume it?';
    PageType = ConfirmationDialog;
    SourceTable = "Sale POS";

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
            }
            group(Details)
            {
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field(Date; Date)
                {
                    ApplicationArea = All;
                }
                field("Start Time"; "Start Time")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Customer Name"; "Customer Name")
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        DrillDownDocument;
                    end;
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        DrillDownDocument;
                    end;
                }
                field("Payment Amount"; "Payment Amount")
                {
                    ApplicationArea = All;

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
        UnfinishedPOSSaleTransact: Page "Unfinished POS Sale Transact.";
    begin
        Clear(UnfinishedPOSSaleTransact);
        UnfinishedPOSSaleTransact.SetRecord(Rec);
        UnfinishedPOSSaleTransact.SetTableView(Rec);
        UnfinishedPOSSaleTransact.RunModal;
    end;
}

