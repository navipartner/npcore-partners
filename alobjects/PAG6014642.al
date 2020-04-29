page 6014642 "RP Data Item Constraints"
{
    AutoSplitKey = true;
    Caption = 'Data Item Constraints';
    PageType = List;
    ShowFilter = false;
    SourceTable = "RP Data Item Constraint";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Constraint Type";"Constraint Type")
                {
                }
                field("Table ID";"Table ID")
                {
                }
                field("Table Name";"Table Name")
                {
                    Editable = false;
                }
            }
            part(Control6014405;"RP Data Item Constraint Links")
            {
                SubPageLink = "Data Item Code"=FIELD("Data Item Code"),
                              "Constraint Line No."=FIELD("Line No.");
            }
        }
    }

    actions
    {
    }
}

