page 6151251 "NPR Retail Enter. Act: Others"
{
    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NPR Retail Entertainment Cue";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            cuegroup("Master Data")
            {
                Caption = 'Master Data';
                field(Items; Rec.Items)
                {

                    ToolTip = 'Specifies the value of the Items field';
                    ApplicationArea = NPRRetail;
                }
                field(Contacts; Rec.Contacts)
                {

                    ToolTip = 'Specifies the value of the Contacts field';
                    ApplicationArea = NPRRetail;
                }
                field(Customers; Rec.Customers)
                {

                    ToolTip = 'Specifies the value of the Customers field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}

