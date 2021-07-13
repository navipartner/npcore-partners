page 6060060 "NPR Item Worksh. Vrty. Mapping"
{
    Caption = 'Item Worksheet Variety Mapping';
    PageType = List;
    SourceTable = "NPR Item Worksh. Vrty Mapping";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Worksheet Template Name"; Rec."Worksheet Template Name")
                {

                    ToolTip = 'Specifies the value of the Worksheet Template Name field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Worksheet Name"; Rec."Worksheet Name")
                {

                    ToolTip = 'Specifies the value of the Worksheet Name field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Vendor No."; Rec."Vendor No.")
                {

                    ToolTip = 'Specifies the value of the Vendor No. field.';
                    ApplicationArea = NPRRetail;
                }
                field("Item Wksh. Maping Field"; Rec."Item Wksh. Maping Field")
                {

                    LookupPageID = "NPR Item Worksh. Field Setup";
                    ToolTip = 'Specifies the value of the Item Worksheet Mapipng Field field.';
                    ApplicationArea = NPRRetail;
                }
                field("Item Wksh. Maping Field Name"; Rec."Item Wksh. Maping Field Name")
                {

                    ToolTip = 'Specifies the value of the Item Worksheet Mapping Field Name field.';
                    ApplicationArea = NPRRetail;
                }
                field("Item Wksh. Maping Field Value"; Rec."Item Wksh. Maping Field Value")
                {

                    ToolTip = 'Specifies the value of the Item Worksheet Mapping Field Value field.';
                    ApplicationArea = NPRRetail;
                }
                field("Vendor Variety Value"; Rec."Vendor Variety Value")
                {

                    ToolTip = 'Specifies the value of the Vendor Variey Value field.';
                    ApplicationArea = NPRRetail;
                }
                field(Variety; Rec.Variety)
                {

                    ToolTip = 'Specifies the value of the Variety field.';
                    ApplicationArea = NPRRetail;
                }
                field("Variety Table"; Rec."Variety Table")
                {

                    ToolTip = 'Specifies the value of the Variety Table field.';
                    ApplicationArea = NPRRetail;
                }
                field("Variety Value"; Rec."Variety Value")
                {

                    ToolTip = 'Specifies the value of the Variety Value field.';
                    ApplicationArea = NPRRetail;
                }
                field("Variety Value Description"; Rec."Variety Value Description")
                {

                    ToolTip = 'Specifies the value of the Variety Value Description field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}

