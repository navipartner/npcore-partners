page 6151126 "NPR NpIa Item AddOn Card"
{
    // NPR5.44/MHA /20180629  CASE 286547 Object created - Item AddOn
    // NPR5.48/MHA /20181206  CASE 334922 Added field "Comment POS Info Code"

    Caption = 'Item AddOn Card';
    PageType = Card;
    SourceTable = "NPR NpIa Item AddOn";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                }
                field("Comment POS Info Code"; "Comment POS Info Code")
                {
                    ApplicationArea = All;
                }
            }
            part(Control6014405; "NPR NpIa Item AddOn Subform")
            {
                SubPageLink = "AddOn No." = FIELD("No.");
            }
        }
    }

    actions
    {
    }
}

