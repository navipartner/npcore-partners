page 6014603 "NPR CleanCash Transactions"
{
    Extensible = False;
    PageType = List;

    UsageCategory = History;
    SourceTable = "NPR CleanCash Trans. Request";
    CardPageId = "NPR CleanCash Transaction Card";
    Caption = 'CleanCash Transactions';
    AdditionalSearchTerms = 'Clean Cash,Swedish Compliance,Audit Handler';
    Editable = false;
    DeleteAllowed = false;
    SourceTableView = order(descending);
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the transactions unique entry number.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {

                    ToolTip = 'Specifies POS Unit making the request.';
                    ApplicationArea = NPRRetail;
                }
                field("Request Type"; Rec."Request Type")
                {

                    ToolTip = 'Specifies the type of transaction.';
                    ApplicationArea = NPRRetail;
                }
                field("Request Datetime"; Rec."Request Datetime")
                {

                    ToolTip = 'Specifies date and time request was created.';
                    ApplicationArea = NPRRetail;
                }
                field("Request Send Status"; Rec."Request Send Status")
                {

                    ToolTip = 'Specifies the send status of transaction.';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt Type"; Rec."Receipt Type")
                {

                    ToolTip = 'Specified type of receipt. Valid values are normal: (Normal sales receipt); kopia: (Copy of sales receipt; ovning: (Training mode sales receipt); profo: (Pro forma receipt).';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt Id"; Rec."Receipt Id")
                {

                    ToolTip = 'Specifies the CleanCash receipt id.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Document No."; Rec."POS Document No.")
                {

                    ToolTip = 'Specifies Document No. from POS sales.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {

                    ToolTip = 'Specifies the internal id of the POS sales.';
                    ApplicationArea = NPRRetail;
                }
                field("Date"; Rec."Receipt DateTime")
                {

                    ToolTip = 'CleanCash receipt date';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt Total"; Rec."Receipt Total")
                {

                    ToolTip = 'Specfies postitive amount of receipt.';
                    ApplicationArea = NPRRetail;
                }
                field("CleanCash Code"; Rec."CleanCash Code")
                {

                    ToolTip = 'Specifies base-32 encoded string to be printed on the receipt and stored in the POS terminal journal.';
                    ApplicationArea = NPRRetail;
                }
                field("CleanCash Main Status"; Rec."CleanCash Main Status")
                {

                    ToolTip = 'Specifies CleanCash Main Status.';
                    ApplicationArea = NPRRetail;
                }
                field("CleanCash Storage Status"; Rec."CleanCash Storage Status")
                {

                    ToolTip = 'Specifies CleanCash Storage Status.';
                    ApplicationArea = NPRRetail;
                }
                field("CleanCash Unit Id"; Rec."CleanCash Unit Id")
                {

                    ToolTip = 'The CleanCash manufacturing id code.';
                    ApplicationArea = NPRRetail;
                }
                field("Organisation No."; Rec."Organisation No.")
                {

                    ToolTip = 'Specifies organisation number of the sender';
                    ApplicationArea = NPRRetail;
                }
                field("Pos Id"; Rec."Pos Id")
                {

                    ToolTip = 'Specifies the POS identity registered with the CleanCash unit.';
                    ApplicationArea = NPRRetail;
                }
                field("Response Count"; Rec."Response Count")
                {

                    Visible = false;
                    ToolTip = 'Specifies the number of response there are for this transaction.';
                    ApplicationArea = NPRRetail;
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

                Image = Open;
                ApplicationArea = NPRRetail;

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

                Image = SendTo;
                ApplicationArea = NPRRetail;
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
