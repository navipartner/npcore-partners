page 6151435 "NPR Magento Attr. Set Values"
{
    Caption = 'Attribute Set Values';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Magento Attr. Set Value";
    SourceTableView = SORTING(Position);

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Attribute ID"; Rec."Attribute ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Attribute ID field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Position; Rec.Position)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Position field';
                }
                field("Attribute Group ID"; Rec."Attribute Group ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Attribute Group ID field';
                }
            }
        }
    }
}