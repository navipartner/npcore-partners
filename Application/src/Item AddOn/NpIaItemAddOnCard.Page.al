page 6151126 "NPR NpIa Item AddOn Card"
{
    Caption = 'Item AddOn Card';
    PageType = Card;
    SourceTable = "NPR NpIa Item AddOn";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the involved entry or record.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the item add-on.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTIp = 'Specifies if the current item add-on is enabled.';
                }
                field("Comment POS Info Code"; Rec."Comment POS Info Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies POS Info Code which will be set in POS info transaction.';
                }
            }
            part(Control6014405; "NPR NpIa Item AddOn Subform")
            {
                SubPageLink = "AddOn No." = FIELD("No.");
                ApplicationArea = All;
            }
        }
    }
}

