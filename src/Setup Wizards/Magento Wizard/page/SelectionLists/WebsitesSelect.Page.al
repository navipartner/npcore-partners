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
                }
                field(Name; Name)
                {
                }
                field("Default Website"; "Default Website")
                {
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
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