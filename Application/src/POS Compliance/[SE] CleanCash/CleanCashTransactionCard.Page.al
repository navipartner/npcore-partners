page 6014543 "NPR CleanCash Transaction Card"
{
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR CleanCash Trans. Request";
    Caption = 'CleanCash Transaction Card';
    Editable = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Caption = 'General';
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
                field("Request Type"; Rec."Request Type")
                {

                    ToolTip = 'Specifies the type of transaction.';
                    ApplicationArea = NPRRetail;

                }
                field("Response Count"; Rec."Response Count")
                {

                    Visible = false;
                    ToolTip = 'Specifies the number of response there are for this transaction.';
                    ApplicationArea = NPRRetail;
                }

            }

            group(IdentityRequest)
            {
                Caption = 'Identity Request';
                Visible = IdentityGroupVisible;
                field(OrganisationNo; Rec."Organisation No.")
                {

                    ToolTip = 'Specifies organisation number of the sender';
                    ApplicationArea = NPRRetail;
                }
                field(PosId; Rec."Pos Id")
                {

                    ToolTip = 'Specifies the POS identity registered with the CleanCash unit.';
                    ApplicationArea = NPRRetail;
                }

            }

            group(StatusRequest)
            {
                Caption = 'Status Request';
                Visible = StatusGroupVisible;
                field(OrganisationNo2; Rec."Organisation No.")
                {

                    ToolTip = 'Specifies organisation number of the sender';
                    ApplicationArea = NPRRetail;
                }
                field(PosId2; Rec."Pos Id")
                {

                    ToolTip = 'Specifies the POS identity registered with the CleanCash unit.';
                    ApplicationArea = NPRRetail;
                }
            }

            group(ReceiptRequest)
            {

                Caption = 'Receipt Request';
                Visible = ReceiptGroupVisible;

                field("Receipt Id"; Rec."Receipt Id")
                {

                    ToolTip = 'Specifies the CleanCash receipt id.';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt Type"; Rec."Receipt Type")
                {

                    ToolTip = 'Specified type of receipt. Valid values are normal: (Normal sales receipt); kopia: (Copy of sales receipt; ovning: (Training mode sales receipt); profo: (Pro forma receipt).';
                    ApplicationArea = NPRRetail;
                }
                field("Date"; Rec."Receipt DateTime")
                {

                    ToolTip = 'CleanCash receipt date';
                    ApplicationArea = NPRRetail;
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {

                    ToolTip = 'Specifies the internal id of the POS sales.';
                    ApplicationArea = NPRRetail;
                }

                field("POS Document No."; Rec."POS Document No.")
                {

                    ToolTip = 'Specifies Document No. from POS sales.';
                    ApplicationArea = NPRRetail;
                }

                field("Receipt Total"; Rec."Receipt Total")
                {

                    ToolTip = 'Specfies postitive amount of receipt.';
                    ApplicationArea = NPRRetail;
                }
                field("Negative Total"; Rec."Negative Total")
                {

                    ToolTip = 'Specfies negative amount of receipt.';
                    ApplicationArea = NPRRetail;
                }

                group(Sender)
                {
                    Caption = 'Originates From';
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

                }

                group(ReceiptResponse)
                {
                    Caption = 'Response';
                    field("CleanCash Code"; Rec."CleanCash Code")
                    {

                        Editable = false;
                        ToolTip = 'Specifies base-32 encoded string to be printed on the receipt and stored in the POS terminal journal.';
                        ApplicationArea = NPRRetail;
                    }
                    field("CleanCash Unit Id"; Rec."CleanCash Unit Id")
                    {

                        Editable = false;
                        ToolTip = 'The CleanCash manufacturing id code.';
                        ApplicationArea = NPRRetail;
                    }
                }

                part(VatDetails; "NPR CleanCash Transaction VAT")
                {

                    SubPageLink = "Request Entry No." = field("Entry No.");
                    SubPageView = sorting("Request Entry No.", "VAT Class");
                    ShowFilter = false;
                    ApplicationArea = NPRRetail;
                }
            }

            group(Resonse)
            {
                Caption = 'Response';
                part(ResponsePart; "NPR CleanCash Response List")
                {

                    SubPageView = sorting("Request Entry No.", "Response No.");
                    SubPageLink = "Request Entry No." = field("Entry No.");
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TrySendRequest)
            {

                Caption = 'Send Request';
                ToolTip = 'If the request does not have status COMPLETE as request status, it can be resent to CleanCash.';
                Image = SendTo;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    CleanCash: Codeunit "NPR CleanCash XCCSP Protocol";
                begin
                    if (Rec."Request Send Status" <> Rec."Request Send Status"::COMPLETE) then
                        CleanCash.HandleRequest(Rec."Entry No.", Rec."Entry No.", true);
                end;

            }
        }

    }

    var
        [InDataSet]
        ReceiptGroupVisible: Boolean;

        [InDataSet]
        IdentityGroupVisible: Boolean;

        [InDataSet]
        StatusGroupVisible: Boolean;


    trigger OnAfterGetRecord()
    var
    begin
        ReceiptGroupVisible := (Rec."Request Type" = Rec."Request Type"::RegisterSalesReceipt) or (Rec."Request Type" = Rec."Request Type"::RegisterReturnReceipt);
        IdentityGroupVisible := (Rec."Request Type" = Rec."Request Type"::IdentityRequest);
        StatusGroupVisible := (Rec."Request Type" = Rec."Request Type"::StatusRequest);
    end;
}