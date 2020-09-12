page 6059962 "NPR MPOS EOD Receipts"
{
    // NPR5.51/CLVA/20190805 CASE 364011 Created object

    Caption = 'MPOS EOD Receips';
    Editable = false;
    PageType = List;
    SourceTable = "NPR MPOS EOD Recipts";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Created By"; "Created By")
                {
                    ApplicationArea = All;
                }
                field(Created; Created)
                {
                    ApplicationArea = All;
                }
                field("Callback Timestamp"; "Callback Timestamp")
                {
                    ApplicationArea = All;
                }
                field("Callback Device Id"; "Callback Device Id")
                {
                    ApplicationArea = All;
                }
                field("Callback Register No."; "Callback Register No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Receipt)
            {
                Caption = 'Receipt';
                Image = CashFlow;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    if not "Callback Receipt 1".HasValue then
                        ReceiptData := ''
                    else begin
                        "Callback Receipt 1".CreateInStream(IStream);
                        IStream.Read(ReceiptData, MaxStrLen(ReceiptData));
                    end;

                    if ReceiptData <> '' then
                        Message(ReceiptData);
                end;
            }
            action(Response)
            {
                Caption = 'Response';
                Image = XMLFile;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    if not "Response Json".HasValue then
                        ResponseData := ''
                    else begin
                        "Response Json".CreateInStream(IStream);
                        IStream.Read(ResponseData, MaxStrLen(ResponseData));
                    end;

                    if ResponseData <> '' then
                        Message(ResponseData);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CalcFields("Response Json", "Callback Receipt 1");
    end;

    var
        ResponseData: Text;
        ReceiptData: Text;
        IStream: InStream;
}

