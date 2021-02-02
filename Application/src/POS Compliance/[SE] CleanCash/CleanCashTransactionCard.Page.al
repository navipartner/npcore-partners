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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the transactions unique entry number.';
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies POS Unit making the request.';
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
                field("Request Type"; Rec."Request Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of transaction.';

                }
                field("Response Count"; Rec."Response Count")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the number of response there are for this transaction.';
                }

            }

            group(IdentityRequest)
            {
                Caption = 'Identity Request';
                Visible = IdentityGroupVisible;
                field(OrganisationNo; Rec."Organisation No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies organisation number of the sender';
                }
                field(PosId; Rec."Pos Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the POS identity registered with the CleanCash unit.';
                }

            }

            group(StatusRequest)
            {
                Caption = 'Status Request';
                Visible = StatusGroupVisible;
                field(OrganisationNo2; Rec."Organisation No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies organisation number of the sender';
                }
                field(PosId2; Rec."Pos Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the POS identity registered with the CleanCash unit.';
                }
            }

            group(ReceiptRequest)
            {

                Caption = 'Receipt Request';
                Visible = ReceiptGroupVisible;

                field("Receipt Id"; Rec."Receipt Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the CleanCash receipt id.';
                }
                field("Receipt Type"; Rec."Receipt Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specified type of receipt. Valid values are normal: (Normal sales receipt); kopia: (Copy of sales receipt; ovning: (Training mode sales receipt); profo: (Pro forma receipt).';
                }
                field("Date"; Rec."Receipt DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'CleanCash receipt date';
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the internal id of the POS sales.';
                }

                field("POS Document No."; Rec."POS Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Document No. from POS sales.';
                }

                field("Receipt Total"; Rec."Receipt Total")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specfies postitive amount of receipt.';
                }
                field("Negative Total"; Rec."Negative Total")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specfies negative amount of receipt.';
                }

                group(Sender)
                {
                    Caption = 'Originates From';
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

                }

                group(ReceiptResponse)
                {
                    Caption = 'Response';
                    field("CleanCash Code"; Rec."CleanCash Code")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies base-32 encoded string to be printed on the receipt and stored in the POS terminal journal.';
                    }
                    field("CleanCash Unit Id"; Rec."CleanCash Unit Id")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'The CleanCash manufacturing id code.';
                    }
                }

                part(VatDetails; "NPR CleanCash Transaction VAT")
                {
                    ApplicationArea = All;
                    SubPageLink = "Request Entry No." = field("Entry No.");
                    SubPageView = sorting("Request Entry No.", "VAT Class");
                    ShowFilter = false;
                }
            }

            group(Resonse)
            {
                Caption = 'Response';
                part(ResponsePart; "NPR CleanCash Response List")
                {
                    ApplicationArea = All;
                    SubPageView = sorting("Request Entry No.", "Response No.");
                    SubPageLink = "Request Entry No." = field("Entry No.");
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
                ApplicationArea = All;
                Caption = 'Send Request';
                ToolTip = 'If the request does not have status COMPLETE as request status, it can be resent to CleanCash.';
                Image = SendTo;

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