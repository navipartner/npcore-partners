page 6151002 "NPR POS Saved Sales"
{
    Caption = 'POS Saved Sales';
    CardPageID = "NPR POS Saved Sale Card";
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR POS Saved Sale Entry";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Sales Ticket No."; Rec."Sales Ticket No.")
                {

                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Created at"; Rec."Created at")
                {

                    ToolTip = 'Specifies the value of the Created at field';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    ToolTip = 'Specifies the value of the Salesperson Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Type"; Rec."Customer Type")
                {

                    ToolTip = 'Specifies the value of the Customer Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer No."; Rec."Customer No.")
                {

                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Price Group"; Rec."Customer Price Group")
                {

                    ToolTip = 'Specifies the value of the Customer Price Group field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Disc. Group"; Rec."Customer Disc. Group")
                {

                    ToolTip = 'Specifies the value of the Customer Disc. Group field';
                    ApplicationArea = NPRRetail;
                }
                field(Attention; Rec.Attention)
                {

                    ToolTip = 'Specifies the value of the Attention field';
                    ApplicationArea = NPRRetail;
                }
                field(Reference; Rec.Reference)
                {

                    ToolTip = 'Specifies the value of the Reference field';
                    ApplicationArea = NPRRetail;
                }
                field(Amount; Rec.Amount)
                {

                    ToolTip = 'Specifies the value of the Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {

                    ToolTip = 'Specifies the value of the Amount Including VAT field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Contains EFT Approval"; Rec."Contains EFT Approval")
                {

                    ToolTip = 'Specifies the value of the Contains EFT Approval field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the View POS Sales Data action';
                ApplicationArea = NPRRetail;

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
