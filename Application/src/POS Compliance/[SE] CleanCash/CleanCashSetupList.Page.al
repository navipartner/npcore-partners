page 6184500 "NPR CleanCash Setup List"
{
    Caption = 'CleanCash POS Unit Setup';
    PageType = List;
    SourceTable = "NPR CleanCash Setup";
    UsageCategory = Administration;

    AdditionalSearchTerms = 'Clean Cash,Swedish Compliance,Audit Handler';
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Register; Rec.Register)
                {
                    Caption = 'POS Unit No.';

                    ToolTip = 'Specifies the CleanCash setup associated with this POS Unit.';
                    ApplicationArea = NPRRetail;
                }
                field("Connection String"; Rec."Connection String")
                {

                    ToolTip = 'Specifies CleanCash connection string. Example: http://<username>:<password>@online.cleancash.se:8081/xccsp';
                    ApplicationArea = NPRRetail;
                }
                field("Organization ID"; Rec."Organization ID")
                {

                    ToolTip = 'Specifies the dealer "Organisation Number" (10 digits).';
                    ApplicationArea = NPRRetail;
                }
                field("CleanCash Register No."; Rec."CleanCash Register No.")
                {

                    ToolTip = 'Specifies the POS Terminal Id registered with CleanCash server.';
                    ApplicationArea = NPRRetail;
                }

                field("CleanCash No. Series"; Rec."CleanCash No. Series")
                {

                    ToolTip = 'Specifies the numberseries used for CleanCash receipt number.';
                    ApplicationArea = NPRRetail;
                }

                field("Last Z Report Time"; Rec."Last Z Report Time")
                {
                    ApplicationArea = NPRRetail;
                    Visible = false;
                    Description = 'Unknow or unclear usage.';
                    ToolTip = 'Specifies the value of the Last Report Time field';
                }

                field(Training; Rec.Training)
                {

                    ToolTip = 'Specifies that the POS is in training mode. This will send receipts to CleanCash, but they will be ignored in an audit. "CleanCash Training Mode" will be printed on the receipt.';
                    ApplicationArea = NPRRetail;
                }
                field("Show Error Message"; Rec."Show Error Message")
                {

                    ToolTip = 'Specifies that CleanCash problems will be show as messages when they occur.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(GetPosCleanCashIdentity)
            {
                Caption = 'Get CleanCash Identity';
                Promoted = true;
                PromotedOnly = true;

                ToolTip = 'Request the CleanCash Unit Identity from CleanCash Server. This will also confirm that your setup is correct.';
                Image = Start;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    RequestType: Enum "NPR CleanCash Request Type";
                begin
#pragma warning disable AA0139
                    ExecuteCleanCashRequest(RequestType::IdentityRequest, Rec.Register);
#pragma warning restore
                end;
            }

            action(GetPosCleanCashStatus)
            {
                Caption = 'Get CleanCash Status';
                Promoted = true;
                PromotedOnly = true;

                ToolTip = 'Request the CleanCash Status from CleanCash Server. This will also confirm that your setup is correct.';
                Image = Start;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    RequestType: Enum "NPR CleanCash Request Type";
                begin
#pragma warning disable AA0139
                    ExecuteCleanCashRequest(RequestType::StatusRequest, Rec.Register);
#pragma warning restore
                end;
            }
        }
    }

    local procedure ExecuteCleanCashRequest(CleanCash: Interface "NPR CleanCash XCCSP Interface"; PosUnitNo: Code[10])
    var
        CleanCashTransaction: Record "NPR CleanCash Trans. Request";
        CleanCashXccsp: Codeunit "NPR CleanCash Xccsp Protocol";
        RequestEntryNo: Integer;
        ResponseEntryNo: Integer;
    begin

        CleanCash.CreateRequest(PosUnitNo, RequestEntryNo);
        CleanCashXccsp.HandleRequest(RequestEntryNo, ResponseEntryNo, true);
        CleanCashTransaction.Get(RequestEntryNo);
        page.Run(page::"NPR CleanCash Transaction Card", CleanCashTransaction);
    end;
}