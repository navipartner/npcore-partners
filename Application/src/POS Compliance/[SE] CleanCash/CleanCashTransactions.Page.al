page 6014603 "NPR CleanCash Transactions"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = History;
    SourceTable = "NPR CleanCash Trans. Request";
    CardPageId = "NPR CleanCash Transaction Card";
    Caption = 'CleanCash Transactions';
    AdditionalSearchTerms = 'Clean Cash,Swedish Compliance,Audit Handler';
    Editable = false;
    DeleteAllowed = false;
    SourceTableView = order(descending);

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the transactions unique entry number.';
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies POS Unit making the request.';
                }
                field("Request Type"; Rec."Request Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of transaction.';
                }
                field("Request Datetime"; Rec."Request Datetime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies date and time request was created.';
                }
                field("Request Send Status"; Rec."Request Send Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the send status of transaction.';
                }
                field("Receipt Type"; Rec."Receipt Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specified type of receipt. Valid values are normal: (Normal sales receipt); kopia: (Copy of sales receipt; ovning: (Training mode sales receipt); profo: (Pro forma receipt).';
                }
                field("Receipt Id"; Rec."Receipt Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the CleanCash receipt id.';
                }
                field("POS Document No."; Rec."POS Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Document No. from POS sales.';
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the internal id of the POS sales.';
                }
                field("Date"; Rec."Receipt DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'CleanCash receipt date';
                }
                field("Receipt Total"; Rec."Receipt Total")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specfies postitive amount of receipt.';
                }
                field("CleanCash Code"; Rec."CleanCash Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies base-32 encoded string to be printed on the receipt and stored in the POS terminal journal.';
                }
                field("CleanCash Main Status"; Rec."CleanCash Main Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies CleanCash Main Status.';
                }
                field("CleanCash Storage Status"; Rec."CleanCash Storage Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies CleanCash Storage Status.';
                }
                field("CleanCash Unit Id"; Rec."CleanCash Unit Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'The CleanCash manufacturing id code.';
                }
                field("Organisation No."; Rec."Organisation No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies organisation number of the sender';
                }
                field("Pos Id"; Rec."Pos Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the POS identity registered with the CleanCash unit.';
                }
                field("Response Count"; Rec."Response Count")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the number of response there are for this transaction.';
                }

            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(CleanCashCard)
            {
                Caption = 'CleanCash Transaction Card';
                Promoted = true;
                PromotedOnly = true;
                Ellipsis = true;
                ToolTip = 'Open Transaction Card';
                ApplicationArea = All;
                Image = Open; 

                trigger OnAction()
                var
                begin
                    Page.Run(page::"NPR CleanCash Transaction Card", Rec);
                end;
            }

        }

        area(Processing)
        {
            action(SendAll)
            {
                Caption = 'Send All';
                ToolTip = 'This action will attempt to send all selected pending or failed transactions';
                ApplicationArea = All;
                Image = SendTo; 
                trigger OnAction()
                var
                    CleanCashTransaction: Record "NPR CleanCash Trans. Request";
                    CleanCash: Codeunit "NPR CleanCash XCCSP Protocol";
                    ResponseEntryNo: Integer;
                begin
                    CurrPage.SetSelectionFilter(CleanCashTransaction);
                    CleanCashTransaction.SetFilter("Request Send Status", '<>%1', CleanCashTransaction."Request Send Status"::COMPLETE);
                    if (CleanCashTransaction.FindSet()) then begin
                        repeat
                            CleanCash.HandleRequest(CleanCashTransaction."Entry No.", ResponseEntryNo, false);
                            Commit();
                        until (CleanCashTransaction.Next() = 0);
                    end
                end;
            }
        }
    }
}