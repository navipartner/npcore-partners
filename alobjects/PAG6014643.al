page 6014643 "RP Data Item Constraint Links"
{
    // NPR5.47/MMV /20181017 CASE 318084 Added field 12

    AutoSplitKey = true;
    Caption = 'Data Item Constraint Links';
    DelayedInsert = true;
    PageType = ListPart;
    ShowFilter = false;
    SourceTable = "RP Data Item Constraint Links";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Data Item Name";"Data Item Name")
                {
                    Enabled = "Filter Type" = 0;
                    Style = Subordinate;
                    StyleExpr = "Filter Type" <> 0;
                    Visible = false;
                }
                field("Data Item Field ID";"Data Item Field ID")
                {
                    Enabled = "Filter Type" = 0;
                    Style = Subordinate;
                    StyleExpr = "Filter Type" <> 0;
                }
                field("Data Item Field Name";"Data Item Field Name")
                {
                    Enabled = "Filter Type" = 0;
                    Style = Subordinate;
                    StyleExpr = "Filter Type" <> 0;
                }
                field("Filter Type";"Filter Type")
                {
                }
                field("Field ID";"Field ID")
                {
                }
                field("Field Name";"Field Name")
                {
                }
                field("Filter Value";"Filter Value")
                {
                    Enabled = "Filter Type"<>0;
                }
                field("Link Type";"Link Type")
                {
                    Enabled = "Filter Type"=0;
                    Style = Subordinate;
                    StyleExpr = "Filter Type"<>0;
                }
            }
        }
    }

    actions
    {
    }
}

