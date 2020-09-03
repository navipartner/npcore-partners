page 6059790 "NPR Pdf2Nav Posting Setup"
{
    // NPR5.36/THRO/20170908 CASE 285645 Setup for Pdf2Nav Posting

    Caption = 'Pdf2Nav Posting Setup';
    PageType = Card;
    SourceTable = "NPR SalesPost Pdf2Nav Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Post and Send"; "Post and Send")
                {
                    ApplicationArea = All;
                }
                group("When posting with Pdf2Nav:")
                {
                    Caption = 'When posting with Pdf2Nav:';
                    field("Always Print Ship"; "Always Print Ship")
                    {
                        ApplicationArea = All;
                    }
                    field("Always Print Receive"; "Always Print Receive")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then
            Insert;
    end;
}

