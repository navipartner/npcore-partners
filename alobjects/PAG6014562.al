page 6014562 "RP Data Item Links"
{
    // NPR5.47/MMV /20181017 CASE 318084 Added field 19

    Caption = 'Data Item Links';
    DelayedInsert = true;
    PageType = ListPart;
    ShowFilter = false;
    SourceTable = "RP Data Item Links";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Parent Field ID";"Parent Field ID")
                {
                    Enabled = "Filter Type"=0;
                    Style = Subordinate;
                    StyleExpr = "Filter Type"<>0;
                }
                field("Parent Field Name";"Parent Field Name")
                {
                    Enabled = "Filter Type"=0;
                    Style = Subordinate;
                    StyleExpr = "Filter Type"<>0;
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

