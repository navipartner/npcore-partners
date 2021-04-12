page 6151002 "NPR POS Saved Sales"
{
    Caption = 'POS Saved Sales';
    CardPageID = "NPR POS Saved Sale Card";
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR POS Saved Sale Entry";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Sales Ticket No."; Rec."Sales Ticket No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }
                field("Register No."; Rec."Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("Created at"; Rec."Created at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created at field';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("Customer Type"; Rec."Customer Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Type field';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field("Customer Price Group"; Rec."Customer Price Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Price Group field';
                }
                field("Customer Disc. Group"; Rec."Customer Disc. Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Disc. Group field';
                }
                field(Attention; Rec.Attention)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Attention field';
                }
                field(Reference; Rec.Reference)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference field';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Including VAT field';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Contains EFT Approval"; Rec."Contains EFT Approval")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contains EFT Approval field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("View POS Sales Data")
            {
                Caption = 'View POS Sales Data';
                Image = XMLFile;
                ApplicationArea = All;
                ToolTip = 'Executes the View POS Sales Data action';

                trigger OnAction()
                var
                    POSQuoteMgt: Codeunit "NPR POS Saved Sale Mgt.";
                begin
                    POSQuoteMgt.ViewPOSSalesData(Rec);
                end;
            }
        }
    }

    var
        IsInEndOfTheDayProcess: Boolean;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        POSQuote: Record "NPR POS Saved Sale Entry";
        EntriesLeft: Label 'You have not closed all the POS Saved Sales. If you continue with the balancing process, the remaining quotes will stay in the system.\Are you sure you want to continue?';
        ConfrimCancel: Label 'Are you sure you want to cancel the balancing process?';
    begin
        if IsInEndOfTheDayProcess then begin
            if CloseAction = ACTION::LookupOK then begin
                if POSQuote.IsEmpty() then
                    exit(true);
                exit(Confirm(EntriesLeft, false));
            end else
                exit(Confirm(ConfrimCancel, false));
        end;
        exit(true);
    end;

    procedure SetIsInEndOfTheDayProcess(Set: Boolean)
    begin
        IsInEndOfTheDayProcess := Set;
    end;
}
