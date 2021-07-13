page 6059962 "NPR MPOS EOD Receipts"
{
    Caption = 'MPOS EOD Receips';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MPOS EOD Recipts";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Created By"; Rec."Created By")
                {

                    ToolTip = 'Specifies the value of the Created By field';
                    ApplicationArea = NPRRetail;
                }
                field(Created; Rec.Created)
                {

                    ToolTip = 'Specifies the value of the Created field';
                    ApplicationArea = NPRRetail;
                }
                field("Callback Timestamp"; Rec."Callback Timestamp")
                {

                    ToolTip = 'Specifies the value of the Callback Timestamp field';
                    ApplicationArea = NPRRetail;
                }
                field("Callback Device Id"; Rec."Callback Device Id")
                {

                    ToolTip = 'Specifies the value of the Callback Device Id field';
                    ApplicationArea = NPRRetail;
                }
                field("Callback Register No."; Rec."Callback Register No.")
                {

                    ToolTip = 'Specifies the value of the Callback Register No. field';
                    ApplicationArea = NPRRetail;
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Receipt action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    if not Rec."Callback Receipt 1".HasValue() then
                        ReceiptData := ''
                    else begin
                        Rec."Callback Receipt 1".CreateInStream(IStream);
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Response action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    if not Rec."Response Json".HasValue() then
                        ResponseData := ''
                    else begin
                        Rec."Response Json".CreateInStream(IStream);
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
        Rec.CalcFields("Response Json", "Callback Receipt 1");
    end;

    var
        ResponseData: Text;
        ReceiptData: Text;
        IStream: InStream;
}

