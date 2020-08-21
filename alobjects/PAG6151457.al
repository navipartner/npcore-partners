page 6151457 "Magento Attribute Group"
{
    // MAG2.18/TS  /20180910  CASE 323934 Attribute Group Created

    Caption = 'Attribute Group';
    DelayedInsert = true;
    Editable = false;
    PageType = CardPart;
    SourceTable = "Magento Attribute Group";
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
                    TableRelation = "Magento Attribute Group" WHERE("Attribute Set ID" = FIELD("Attribute Set ID"));
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Attribute Set ID"; "Attribute Set ID")
                {
                    ApplicationArea = All;
                }
                field("Sort Order"; "Sort Order")
                {
                    ApplicationArea = All;
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

