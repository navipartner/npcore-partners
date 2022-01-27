page 6014642 "NPR RP Data Item Constr."
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'Data Item Constraints';
    PageType = List;
    UsageCategory = Administration;

    ShowFilter = false;
    SourceTable = "NPR RP Data Item Constr.";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Constraint Type"; Rec."Constraint Type")
                {

                    ToolTip = 'Specifies the value of the Constraint Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Table ID"; Rec."Table ID")
                {

                    ToolTip = 'Specifies the value of the Table ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Table Name"; Rec."Table Name")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Table Name field';
                    ApplicationArea = NPRRetail;
                }
            }
            part(Control6014405; "NPR RP Data Item Constr. Links")
            {
                SubPageLink = "Data Item Code" = FIELD("Data Item Code"),
                              "Constraint Line No." = FIELD("Line No.");
                ApplicationArea = NPRRetail;

            }
        }
    }

    actions
    {
    }
}

