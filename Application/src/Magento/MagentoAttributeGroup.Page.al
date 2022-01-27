page 6151457 "NPR Magento Attribute Group"
{
    Extensible = False;
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
                field("Attribute Group ID"; Rec."Attribute Group ID")
                {

                    TableRelation = "NPR Magento Attribute Group" WHERE("Attribute Set ID" = FIELD("Attribute Set ID"));
                    ToolTip = 'Specifies the value of the Attribute Group ID field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Attribute Set ID"; Rec."Attribute Set ID")
                {

                    ToolTip = 'Specifies the value of the Attribute Set ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Sort Order"; Rec."Sort Order")
                {

                    ToolTip = 'Specifies the value of the Sort Order field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }


    trigger OnClosePage()
    begin
        Rec.TestField("Attribute Group ID");
        Rec.TestField("Attribute Set ID");
    end;
}
