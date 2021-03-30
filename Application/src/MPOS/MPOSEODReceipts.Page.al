page 6059962 "NPR MPOS EOD Receipts"
{
    Caption = 'MPOS EOD Receips';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MPOS EOD Recipts";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created By field';
                }
                field(Created; Rec.Created)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created field';
                }
                field("Callback Timestamp"; Rec."Callback Timestamp")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback Timestamp field';
                }
                field("Callback Device Id"; Rec."Callback Device Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback Device Id field';
                }
                field("Callback Register No."; Rec."Callback Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback Register No. field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Receipt action';

                trigger OnAction()
                begin
                    if not Rec."Callback Receipt 1".HasValue then
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
                ApplicationArea = All;
                ToolTip = 'Executes the Response action';

                trigger OnAction()
                begin
                    if not Rec."Response Json".HasValue then
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

