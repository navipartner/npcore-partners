page 6151126 "NPR NpIa Item AddOn Card"
{
    UsageCategory = None;
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

                    ToolTip = 'Specifies the number of the involved entry or record.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies a description of the item add-on.';
                    ApplicationArea = NPRRetail;
                }
                field(Enabled; Rec.Enabled)
                {

                    ToolTIp = 'Specifies if the current item add-on is enabled.';
                    ApplicationArea = NPRRetail;
                }
                field("Comment POS Info Code"; Rec."Comment POS Info Code")
                {

                    ToolTip = 'Specifies POS Info Code which will be set in POS info transaction.';
                    ApplicationArea = NPRRetail;
                }
            }
            part(Control6014405; "NPR NpIa Item AddOn Subform")
            {
                SubPageLink = "AddOn No." = FIELD("No.");
                ApplicationArea = NPRRetail;

            }
        }
    }
}

