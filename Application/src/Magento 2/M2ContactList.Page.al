page 6014458 "NPR M2 Contact List"
{
    Extensible = False;
    Caption = 'Magento Contact List';
    PageType = List;

    UsageCategory = Lists;
    SourceTable = "NPR M2 Contact Buffer";
    Editable = False;
    SourceTableTemporary = True;
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field';

                    Editable = false;
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = NPRRetail;

                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ToolTip = 'Specifies the value of the Customer Name field';
                    ApplicationArea = NPRRetail;

                }
                field("Contact No."; Rec."Contact No.")
                {
                    ToolTip = 'Specifies the value of the Contact No. field';
                    ApplicationArea = NPRRetail;

                }
                field("Contact Name"; Rec."Contact Name")
                {
                    ToolTip = 'Specifies the value of the Contact Name field';
                    ApplicationArea = NPRRetail;

                }
                field("Contact Email"; Rec."Contact Email")
                {
                    ToolTip = 'Specifies the value of the Contact Email field';
                    ApplicationArea = NPRRetail;

                }
                field("Magento Store Code"; Rec."Magento Store Code")
                {
                    ToolTip = 'Specifies the value of the Magento Store Code field';

                    Editable = false;
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Magento Contact"; Rec."Magento Contact")
                {
                    ToolTip = 'Specifies the value of the Magento Contact field';

                    Editable = false;
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Password Reset"; Rec."Password Reset")
                {
                    ToolTip = 'Specifies the value of the Password Reset field';

                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ToolTip = 'Specifies the value of the Error Message field';

                    Editable = false;
                    Style = Attention;
                    StyleExpr = true;
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Reset Password Of Contacts")
            {

                Image = Email;
                Caption = 'Reset Password Of Contacts';
                ToolTip = 'Reset Passwords of the Contacts';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    M2AccountManager.ResetPasswordAllMagentoContacts(Rec);
                end;
            }
        }
    }
    var
        M2AccountManager: Codeunit "NPR M2 Account Manager";
}
