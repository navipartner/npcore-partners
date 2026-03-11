#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
page 6248196 "NPR NPRE Menu Item Translat."
{
    Extensible = false;
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = None;
    SourceTable = "NPR NPRE Menu Item Translation";


    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Language Code"; Rec."Language Code")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Language Code';
                    ToolTip = 'Specifies the language code for this translation.';
                }
                field(Title; Rec.Title)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Title';
                    ToolTip = 'Specifies the translated title.';
                }
                field(DescDefined; Rec."Description Markdown".HasValue())
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Description Filled';
                    ToolTip = 'Specifies whether a description has been provided.';
                }
                field(NutritionDefined; Rec."Nutritional Info Markdown".HasValue())
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Nutrition Filled';
                    ToolTip = 'Specifies whether nutritional information has been provided.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ChangeDetails)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Add Details';
                Image = Edit;
                ToolTip = 'Add or edit the description and nutritional information for this item.';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = Page "NPR NPRE Menu Item Tra. Det.";
                RunPageLink = "External System Id" = field("External System Id"), "Language Code" = field("Language Code");
            }
        }
    }
}
#endif
