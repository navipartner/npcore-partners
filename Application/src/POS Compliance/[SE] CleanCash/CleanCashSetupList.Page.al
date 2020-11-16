page 6184500 "NPR CleanCash Setup List"
{

    Caption = 'CleanCash POS Unit Setup';
    PageType = List;
    SourceTable = "NPR CleanCash Setup";
    UsageCategory = Administration;
    ApplicationArea = All;
    AdditionalSearchTerms = 'Clean Cash,Swedish Compliance,Audit Handler';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Register; Register)
                {
                    Caption = 'POS Unit No.';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the CleanCash setup associated with this POS Unit.';
                }
                field("Connection String"; "Connection String")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies CleanCash connection string. Example: http://<username>:<password>@online.cleancash.se:8081/xccsp';
                }
                field("Organization ID"; "Organization ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the dealer "Organisation Number" (10 digits).';
                }
                field("CleanCash Register No."; "CleanCash Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the POS Terminal Id registered with CleanCash server.';
                }

                field("CleanCash No. Series"; "CleanCash No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the numberseries used for CleanCash receipt number.';
                }

                field("Last Z Report Time"; "Last Z Report Time")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = '';
                    Description = 'Unknow or unclear usage.';
                }

                field(Training; Training)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies that the POS is in training mode. This will send receipts to CleanCash, but they will be ignored in an audit. "CleanCash Training Mode" will be printed on the receipt.';
                }
                field("Show Error Message"; "Show Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies that CleanCash problems will be show as messages when they occur.';
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
                ApplicationArea = All;
                ToolTip = 'Request the CleanCash Unit Identity from CleanCash Server. This will also confirm that your setup is correct.';
                trigger OnAction()
                var
                    RequestType: Enum "NPR CleanCash Request Type";
                begin
                    ExecuteCleanCashRequest(RequestType::IdentityRequest, Rec.Register);
                end;
            }

            action(GetPosCleanCashStatus)
            {
                Caption = 'Get CleanCash Status';
                Promoted = true;
                ApplicationArea = All;
                ToolTip = 'Request the CleanCash Status from CleanCash Server. This will also confirm that your setup is correct.';
                trigger OnAction()
                var
                    RequestType: Enum "NPR CleanCash Request Type";
                begin
                    ExecuteCleanCashRequest(RequestType::StatusRequest, Rec.Register);
                end;
            }
        }
    }

    local procedure ExecuteCleanCashRequest(CleanCash: Interface "NPR CleanCash XCCSP Interface"; PosUnitNo: Code[10])
    var
        CleanCashTransaction: Record "NPR CleanCash Trans. Request";
        CleanCashXccsp: Codeunit "NPR CleanCash Xccsp Protocol";
        RequestType: Enum "NPR CleanCash Request Type";
        RequestEntryNo: Integer;
        ResponseEntryNo: Integer;
    begin
        CleanCash.CreateRequest(Rec.Register, RequestEntryNo);
        CleanCashXccsp.HandleRequest(RequestEntryNo, ResponseEntryNo, true);
        CleanCashTransaction.Get(RequestEntryNo);
        page.Run(page::"NPR CleanCash Transaction Card", CleanCashTransaction);
    end;
}

