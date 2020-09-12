page 6014642 "NPR RP Data Item Constr."
{
    AutoSplitKey = true;
    Caption = 'Data Item Constraints';
    PageType = List;
    ShowFilter = false;
    SourceTable = "NPR RP Data Item Constr.";

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
            part(Control6014405; "NPR RP Data Item Constr. Links")
            {
                SubPageLink = "Data Item Code" = FIELD("Data Item Code"),
                              "Constraint Line No." = FIELD("Line No.");
                ApplicationArea = All;
            }
        }
    }

    actions
    {
    }
}

