page 6151458 "NPR Magento Attr. Group List"
{
    Extensible = False;
    Caption = 'Attribute Groups';
    Editable = true;
    PageType = List;
    SourceTable = "NPR Magento Attribute Group";
    SourceTableView = SORTING("Attribute Group ID")
                      ORDER(Ascending);
    UsageCategory = Lists;
    ApplicationArea = NPRMagento;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Attribute Group ID"; Rec."Attribute Group ID")
                {

                    ToolTip = 'Specifies the value of the Attribute Group ID field';
                    ApplicationArea = NPRMagento;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRMagento;
                }
                field("Attribute Set ID"; Rec."Attribute Set ID")
                {

                    ToolTip = 'Specifies the value of the Attribute Set ID field';
                    ApplicationArea = NPRMagento;
                }
                field("Sort Order"; Rec."Sort Order")
                {

                    ToolTip = 'Specifies the value of the Sort Order field';
                    ApplicationArea = NPRMagento;
                }
            }
        }
    }
}
