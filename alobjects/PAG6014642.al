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
                field("Constraint Type"; "Constraint Type")
                {
                    ApplicationArea = All;
                }
                field("Table ID"; "Table ID")
                {
                    ApplicationArea = All;
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            part(Control6014405; "RP Data Item Constraint Links")
            {
                SubPageLink = "Data Item Code" = FIELD("Data Item Code"),
                              "Constraint Line No." = FIELD("Line No.");
            }
        }
    }

    actions
    {
    }
}

