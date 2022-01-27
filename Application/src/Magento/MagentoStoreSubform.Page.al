page 6151408 "NPR Magento Store Subform"
{
    Extensible = False;
    Caption = 'Magento Store Subform';
    InsertAllowed = false;
    PageType = ListPart;
    UsageCategory = Administration;

    ShowFilter = false;
    SourceTable = "NPR Magento Store";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
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
                field("Language Code"; Rec."Language Code")
                {

                    ToolTip = 'Specifies the value of the Language Code field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
