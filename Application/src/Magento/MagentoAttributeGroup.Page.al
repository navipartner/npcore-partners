page 6151457 "NPR Magento Attribute Group"
{
    // MAG2.18/TS  /20180910  CASE 323934 Attribute Group Created

    UsageCategory = None;
    Caption = 'Attribute Group';
    DelayedInsert = true;
    Editable = false;
    PageType = CardPart;
    SourceTable = "NPR Magento Attribute Group";
    SourceTableView = SORTING("Attribute Group ID")
                      ORDER(Ascending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Attribute Group ID"; "Attribute Group ID")
                {
                    ApplicationArea = All;
                    TableRelation = "NPR Magento Attribute Group" WHERE("Attribute Set ID" = FIELD("Attribute Set ID"));
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

    trigger OnClosePage()
    begin
        TestField("Attribute Group ID");
        TestField("Attribute Set ID");
    end;
}

