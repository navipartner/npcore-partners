page 6014620 "NPR Websites Select"
{
    Caption = 'Websites';
    PageType = List;
    SourceTable = "NPR Magento Website";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Websites)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Default Website"; "Default Website")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    procedure SetRec(var TempMagentoWebsite: Record "NPR Magento Website")
    begin
        if TempMagentoWebsite.FindSet() then
            repeat
                Rec := TempMagentoWebsite;
                Rec.Insert();
            until TempMagentoWebsite.Next() = 0;
    end;
}