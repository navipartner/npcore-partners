page 6060060 "NPR Item Worksh. Vrty. Mapping"
{
    Caption = 'Item Worksheet Variety Mapping';
    PageType = List;
    SourceTable = "NPR Item Worksh. Vrty Mapping";
    UsageCategory = Lists;
    ApplicationArea = All; 
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Worksheet Template Name"; Rec."Worksheet Template Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Worksheet Template Name field.';
                    Visible = false;
                }
                field("Worksheet Name"; Rec."Worksheet Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Worksheet Name field.';
                    Visible = false;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor No. field.';
                }
                field("Item Wksh. Maping Field"; Rec."Item Wksh. Maping Field")
                {
                    ApplicationArea = All;
                    LookupPageID = "NPR Item Worksh. Field Setup";
                    ToolTip = 'Specifies the value of the Item Worksheet Mapipng Field field.';
                }
                field("Item Wksh. Maping Field Name"; Rec."Item Wksh. Maping Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Worksheet Mapping Field Name field.';
                }
                field("Item Wksh. Maping Field Value"; Rec."Item Wksh. Maping Field Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Worksheet Mapping Field Value field.';
                }
                field("Vendor Variety Value"; Rec."Vendor Variety Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor Variey Value field.';
                }
                field(Variety; Rec.Variety)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety field.';
                }
                field("Variety Table"; Rec."Variety Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety Table field.';
                }
                field("Variety Value"; Rec."Variety Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety Value field.';
                }
                field("Variety Value Description"; Rec."Variety Value Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety Value Description field.';
                }
            }
        }
    }

}

