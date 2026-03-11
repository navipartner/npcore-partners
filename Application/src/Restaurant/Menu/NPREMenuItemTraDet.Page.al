#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
page 6150915 "NPR NPRE Menu Item Tra. Det."
{
    Extensible = false;
    ApplicationArea = NPRRetail;
    Caption = 'Menu Item Translation Details';
    PageType = Card;
    SourceTable = "NPR NPRE Menu Item Translation";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(Details)
            {
                Caption = 'Details';
                field(ItemDescription; ItemDescriptionText)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Item Description (Markdown)';
                    MultiLine = true;
                    ToolTip = 'Specifies the full description of the menu item in markdown format.';

                    trigger OnValidate()
                    begin
                        Rec.SetItemDescription(ItemDescriptionText);
                        Rec.Modify(true);
                    end;
                }
                field(NutritionalInfo; NutritionalInfoText)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Nutritional Info (Markdown)';
                    MultiLine = true;
                    ToolTip = 'Specifies nutritional information and allergen details in markdown format.';

                    trigger OnValidate()
                    begin
                        Rec.SetNutritionalInfo(NutritionalInfoText);
                        Rec.Modify(true);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ItemDescriptionText := Rec.GetItemDescription();
        NutritionalInfoText := Rec.GetNutritionalInfo();
    end;

    var
        ItemDescriptionText: Text;
        NutritionalInfoText: Text;
}
#endif
