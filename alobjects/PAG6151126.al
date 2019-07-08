page 6151126 "NpIa Item AddOn Card"
{
    // NPR5.44/MHA /20180629  CASE 286547 Object created - Item AddOn
    // NPR5.48/MHA /20181206  CASE 334922 Added field "Comment POS Info Code"

    Caption = 'Item AddOn Card';
    PageType = Card;
    SourceTable = "NpIa Item AddOn";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No.";"No.")
                {
                }
                field(Description;Description)
                {
                }
                field(Enabled;Enabled)
                {
                }
                field("Comment POS Info Code";"Comment POS Info Code")
                {
                }
            }
            part(Control6014405;"NpIa Item AddOn Subform")
            {
                SubPageLink = "AddOn No."=FIELD("No.");
            }
        }
    }

    actions
    {
    }
}

