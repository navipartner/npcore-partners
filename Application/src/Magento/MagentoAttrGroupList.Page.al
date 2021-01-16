page 6151458 "NPR Magento Attr. Group List"
{
    // MAG2.18/TS  /20180910  CASE 323934 Attribute Group Created

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
                field("Attribute Group ID"; "Attribute Group ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Attribute Group ID field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Attribute Set ID"; "Attribute Set ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Attribute Set ID field';
                }
                field("Sort Order"; "Sort Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sort Order field';
                }
            }
        }
    }

    actions
    {
    }
}

