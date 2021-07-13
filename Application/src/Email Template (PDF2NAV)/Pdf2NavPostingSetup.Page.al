page 6059790 "NPR Pdf2Nav Posting Setup"
{
    Caption = 'Pdf2Nav Posting Setup';
    PageType = Card;
    SourceTable = "NPR SalesPost Pdf2Nav Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group(General)
            {
                field("Post and Send"; Rec."Post and Send")
                {

                    ToolTip = 'Specifies the value of the Post and Send field';
                    ApplicationArea = NPRRetail;
                }
                group("When posting with Pdf2Nav:")
                {
                    Caption = 'When posting with Pdf2Nav:';
                    field("Always Print Ship"; Rec."Always Print Ship")
                    {

                        ToolTip = 'Specifies the value of the Always Print Sales Shipment field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Always Print Receive"; Rec."Always Print Receive")
                    {

                        ToolTip = 'Specifies the value of the Always Print Sales Return Receipt field';
                        ApplicationArea = NPRRetail;
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

