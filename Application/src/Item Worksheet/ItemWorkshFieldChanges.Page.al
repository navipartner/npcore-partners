page 6060055 "NPR Item Worksh. Field Changes"
{
    Caption = 'Item Worksheet Field Changes';
    Editable = false;
    PageType = List;
    SourceTable = "NPR Item Worksh. Field Change";
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
                    ToolTip = 'Specifies the value of the Journal Template Name field.';
                    Visible = false;
                }
                field("Worksheet Name"; Rec."Worksheet Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field.';
                    Visible = false;
                }
                field("Worksheet Line No."; Rec."Worksheet Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Worksheet Line No. field.';
                    Visible = false;
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field.';
                    Visible = false;
                }
                field("Field Number"; Rec."Field Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Number field.';
                    Visible = false;
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field.';
                    Visible = false;
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Caption field.';
                }
                field("Target Table No. Update"; Rec."Target Table No. Update")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Target Table No. Update field.';
                    Visible = false;
                }
                field("Target Field Number Update"; Rec."Target Field Number Update")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Target Field Number Update field.';
                    Visible = false;
                }
                field("Target Field Name Update"; Rec."Target Field Name Update")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Target Field Name Update field.';
                    Visible = false;
                }
                field("Target Field Caption Update"; Rec."Target Field Caption Update")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Target Field Caption Update field.';
                }
                field("Current Value"; Rec."Current Value")
                {
                    ApplicationArea = All;
                    Style = Unfavorable;
                    StyleExpr = Rec.Warning;
                    ToolTip = 'Specifies the value of the Current Value field.';
                }
                field("New Value"; Rec."New Value")
                {
                    ApplicationArea = All;
                    Style = Unfavorable;
                    StyleExpr = Rec.Warning;
                    ToolTip = 'Specifies the value of the New Value field.';
                }
                field(Warning; Rec.Warning)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Warning field.';
                }
                field(Process; Rec.Process)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Process field.';
                }
            }
        }
    }

}

