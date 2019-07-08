page 6060055 "Item Worksheet Field Changes"
{
    // NPR5.25\BR  \20160720  CASE 246088 Object Created
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to Object

    Caption = 'Item Worksheet Field Changes';
    Editable = false;
    PageType = List;
    SourceTable = "Item Worksheet Field Change";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Worksheet Template Name";"Worksheet Template Name")
                {
                    Visible = false;
                }
                field("Worksheet Name";"Worksheet Name")
                {
                    Visible = false;
                }
                field("Worksheet Line No.";"Worksheet Line No.")
                {
                    Visible = false;
                }
                field("Table No.";"Table No.")
                {
                    Visible = false;
                }
                field("Field Number";"Field Number")
                {
                    Visible = false;
                }
                field("Field Name";"Field Name")
                {
                    Visible = false;
                }
                field("Field Caption";"Field Caption")
                {
                }
                field("Target Table No. Update";"Target Table No. Update")
                {
                    Visible = false;
                }
                field("Target Field Number Update";"Target Field Number Update")
                {
                    Visible = false;
                }
                field("Target Field Name Update";"Target Field Name Update")
                {
                    Visible = false;
                }
                field("Target Field Caption Update";"Target Field Caption Update")
                {
                }
                field("Current Value";"Current Value")
                {
                    Style = Unfavorable;
                    StyleExpr = Warning;
                }
                field("New Value";"New Value")
                {
                    Style = Unfavorable;
                    StyleExpr = Warning;
                }
                field(Warning;Warning)
                {
                }
                field(Process;Process)
                {
                }
            }
        }
    }

    actions
    {
    }
}

