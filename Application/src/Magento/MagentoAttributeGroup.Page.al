page 6151457 "NPR Magento Attribute Group"
{
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
                    ApplicationArea = All;
                    TableRelation = "NPR Magento Attribute Group" WHERE("Attribute Set ID" = FIELD("Attribute Set ID"));
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


    trigger OnClosePage()
    begin
        Rec.TestField("Attribute Group ID");
        Rec.TestField("Attribute Set ID");
    end;
}