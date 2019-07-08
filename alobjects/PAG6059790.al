page 6059790 "Pdf2Nav Posting Setup"
{
    // NPR5.36/THRO/20170908 CASE 285645 Setup for Pdf2Nav Posting

    Caption = 'Pdf2Nav Posting Setup';
    PageType = Card;
    SourceTable = "Sales-Post and Pdf2Nav Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Post and Send";"Post and Send")
                {
                }
                group("When posting with Pdf2Nav:")
                {
                    Caption = 'When posting with Pdf2Nav:';
                    field("Always Print Ship";"Always Print Ship")
                    {
                    }
                    field("Always Print Receive";"Always Print Receive")
                    {
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

