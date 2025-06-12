page 6184857 "NPR WalletTemplateCard"
{
    Extensible = False;
    UsageCategory = None;
    Caption = 'Package Template Card';
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
                    ToolTip = 'Specifies a description of the item template.';
                    ApplicationArea = NPRRetail;
                }
                field(Enabled; Rec.Enabled)
                {
                    ToolTIp = 'Specifies if the current item template is enabled.';
                    ApplicationArea = NPRRetail;
                }
                field("Comment POS Info Code"; Rec."Comment POS Info Code")
                {

                    ToolTip = 'Specifies POS Info Code which will be set in POS info transaction.';
                    ApplicationArea = NPRRetail;
                }
                field(WalletTemplate; Rec.WalletTemplate)
                {
                    ToolTip = 'Specifies if the current item template is a wallet template.';
                    ApplicationArea = NPRRetail;
                }
            }
            part(Control6014405; "NPR WalletTemplateLines")
            {
                SubPageLink = "AddOn No." = FIELD("No.");
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.WalletTemplate := true;
    end;
}
