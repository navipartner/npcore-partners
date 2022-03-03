page 6014620 "NPR Websites Select"
{
    Extensible = False;
    Caption = 'Websites';
    PageType = List;
    UsageCategory = None;

    SourceTable = "NPR Magento Website";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Websites)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Default Website"; Rec."Default Website")
                {

                    ToolTip = 'Specifies the value of the Std. Website field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ToolTip = 'Specifies the code of the responsibility center, such as a distribution hub, that is associated with the involved user, company, customer, or vendor. When webshop order is created and imported to Business Central, if Code of this Website is named, then value from this field will be passed to the Sales Header.';
                    ApplicationArea = NPRRetail;
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
