page 6059790 "NPR Pdf2Nav Posting Setup"
{
    Caption = 'Pdf2Nav Posting Setup';
    PageType = Card;
    SourceTable = "NPR SalesPost Pdf2Nav Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Post and Send"; Rec."Post and Send")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post and Send field';
                }
                group("When posting with Pdf2Nav:")
                {
                    Caption = 'When posting with Pdf2Nav:';
                    field("Always Print Ship"; Rec."Always Print Ship")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Always Print Sales Shipment field';
                    }
                    field("Always Print Receive"; Rec."Always Print Receive")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Always Print Sales Return Receipt field';
                    }
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then
            Rec.Insert();
    end;
}

