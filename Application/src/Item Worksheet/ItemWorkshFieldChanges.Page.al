page 6060055 "NPR Item Worksh. Field Changes"
{
    Extensible = False;
    Caption = 'Item Worksheet Field Changes';
    Editable = false;
    PageType = List;
    SourceTable = "NPR Item Worksh. Field Change";
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

                    ToolTip = 'Specifies the value of the Journal Template Name field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Worksheet Name"; Rec."Worksheet Name")
                {

                    ToolTip = 'Specifies the value of the Name field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Worksheet Line No."; Rec."Worksheet Line No.")
                {

                    ToolTip = 'Specifies the value of the Worksheet Line No. field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Table No."; Rec."Table No.")
                {

                    ToolTip = 'Specifies the value of the Table No. field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Field Number"; Rec."Field Number")
                {

                    ToolTip = 'Specifies the value of the Field Number field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Field Name"; Rec."Field Name")
                {

                    ToolTip = 'Specifies the value of the Field Name field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Field Caption"; Rec."Field Caption")
                {

                    ToolTip = 'Specifies the value of the Field Caption field.';
                    ApplicationArea = NPRRetail;
                }
                field("Target Table No. Update"; Rec."Target Table No. Update")
                {

                    ToolTip = 'Specifies the value of the Target Table No. Update field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Target Field Number Update"; Rec."Target Field Number Update")
                {

                    ToolTip = 'Specifies the value of the Target Field Number Update field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Target Field Name Update"; Rec."Target Field Name Update")
                {

                    ToolTip = 'Specifies the value of the Target Field Name Update field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Target Field Caption Update"; Rec."Target Field Caption Update")
                {

                    ToolTip = 'Specifies the value of the Target Field Caption Update field.';
                    ApplicationArea = NPRRetail;
                }
                field("Current Value"; Rec."Current Value")
                {

                    Style = Unfavorable;
                    StyleExpr = Rec.Warning;
                    ToolTip = 'Specifies the value of the Current Value field.';
                    ApplicationArea = NPRRetail;
                }
                field("New Value"; Rec."New Value")
                {

                    Style = Unfavorable;
                    StyleExpr = Rec.Warning;
                    ToolTip = 'Specifies the value of the New Value field.';
                    ApplicationArea = NPRRetail;
                }
                field(Warning; Rec.Warning)
                {

                    ToolTip = 'Specifies the value of the Warning field.';
                    ApplicationArea = NPRRetail;
                }
                field(Process; Rec.Process)
                {

                    ToolTip = 'Specifies the value of the Process field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}

