page 6060055 "NPR Item Worksh. Field Changes"
{
    // NPR5.25\BR  \20160720  CASE 246088 Object Created
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to Object

    Caption = 'Item Worksheet Field Changes';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Item Worksh. Field Change";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Worksheet Template Name"; "Worksheet Template Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Journal Template Name field';
                }
                field("Worksheet Name"; "Worksheet Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Worksheet Line No."; "Worksheet Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Worksheet Line No. field';
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("Field Number"; "Field Number")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Field Number field';
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
                field("Field Caption"; "Field Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Caption field';
                }
                field("Target Table No. Update"; "Target Table No. Update")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Target Table No. Update field';
                }
                field("Target Field Number Update"; "Target Field Number Update")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Target Field Number Update field';
                }
                field("Target Field Name Update"; "Target Field Name Update")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Target Field Name Update field';
                }
                field("Target Field Caption Update"; "Target Field Caption Update")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Target Field Caption Update field';
                }
                field("Current Value"; "Current Value")
                {
                    ApplicationArea = All;
                    Style = Unfavorable;
                    StyleExpr = Warning;
                    ToolTip = 'Specifies the value of the Current Value field';
                }
                field("New Value"; "New Value")
                {
                    ApplicationArea = All;
                    Style = Unfavorable;
                    StyleExpr = Warning;
                    ToolTip = 'Specifies the value of the New Value field';
                }
                field(Warning; Warning)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Warning field';
                }
                field(Process; Process)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Process field';
                }
            }
        }
    }

    actions
    {
    }
}

