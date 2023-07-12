page 6151002 "NPR POS Saved Sales"
{
    Extensible = False;
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

                    ToolTip = 'Specifies the sales ticket number.';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the POS unit number.';
                    ApplicationArea = NPRRetail;
                }
                field("Created at"; Rec."Created at")
                {

                    ToolTip = 'Specifies the creation date of the entry.';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    ToolTip = 'Specifies the salesperson code.';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Type"; Rec."Customer Type")
                {

                    ToolTip = 'Specifies the customer type.';
                    ApplicationArea = NPRRetail;
                    ObsoleteState = Pending;
                    ObsoleteTag = 'NPR23.0';
                    ObsoleteReason = 'Not used';
                }
                field("Customer No."; Rec."Customer No.")
                {

                    ToolTip = 'Specifies the customer number.';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Price Group"; Rec."Customer Price Group")
                {

                    ToolTip = 'Specifies the customer price group.';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Disc. Group"; Rec."Customer Disc. Group")
                {

                    ToolTip = 'Specifies the customer discount group.';
                    ApplicationArea = NPRRetail;
                }
                field(Attention; Rec.Attention)
                {

                    ToolTip = 'Specifies the attention for this entry';
                    ApplicationArea = NPRRetail;
                }
                field(Reference; Rec.Reference)
                {

                    ToolTip = 'Specifies the reference of the entry.';
                    ApplicationArea = NPRRetail;
                }
                field(Amount; Rec.Amount)
                {

                    ToolTip = 'Specifies the sales amount.';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {

                    ToolTip = 'Specifies the amount including VAT.';
                    ApplicationArea = NPRRetail;
                }
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the entry number.';
                    ApplicationArea = NPRRetail;
                }
                field("Contains EFT Approval"; Rec."Contains EFT Approval")
                {

                    ToolTip = 'Specifies if the entry contains EFT approval.';
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

                ToolTip = 'Displays the POS sales data.';
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

    internal procedure SetIsInEndOfTheDayProcess(Set: Boolean)
    begin
        IsInEndOfTheDayProcess := Set;
    end;
}
