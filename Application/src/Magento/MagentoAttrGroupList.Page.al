page 6151458 "NPR Magento Attr. Group List"
{
    Caption = 'Attribute Groups';
    Editable = true;
    PageType = List;
    SourceTable = "NPR Magento Attribute Group";
    SourceTableView = SORTING("Attribute Group ID")
                      ORDER(Ascending);
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Attribute Group ID"; Rec."Attribute Group ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Attribute Group ID field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Attribute Set ID"; Rec."Attribute Set ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Attribute Set ID field';
                }
                field("Sort Order"; Rec."Sort Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sort Order field';
                }
            }
        }
    }
}