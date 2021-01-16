page 6014620 "NPR Websites Select"
{
    Caption = 'Websites';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Default Website"; "Default Website")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Std. Website field';
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
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
