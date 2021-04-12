page 6014642 "NPR RP Data Item Constr."
{
    AutoSplitKey = true;
    Caption = 'Data Item Constraints';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    ShowFilter = false;
    SourceTable = "NPR RP Data Item Constr.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Constraint Type"; Rec."Constraint Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Constraint Type field';
                }
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table ID field';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Table Name field';
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

