page 6014458 "NPR M2 Contact List"
{
    Caption = 'Magento Contact List';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "NPR M2 Contact Buffer";
    Editable = False;
    SourceTableTemporary = True;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = All;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ToolTip = 'Specifies the value of the Customer Name field';
                    ApplicationArea = All;
                }
                field("Contact No."; Rec."Contact No.")
                {
                    ToolTip = 'Specifies the value of the Contact No. field';
                    ApplicationArea = All;
                }
                field("Contact Name"; Rec."Contact Name")
                {
                    ToolTip = 'Specifies the value of the Contact Name field';
                    ApplicationArea = All;
                }
                field("Contact Email"; Rec."Contact Email")
                {
                    ToolTip = 'Specifies the value of the Contact Email field';
                    ApplicationArea = All;
                }
                field("Magento Store Code"; Rec."Magento Store Code")
                {
                    ToolTip = 'Specifies the value of the Magento Store Code field';
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Magento Contact"; Rec."Magento Contact")
                {
                    ToolTip = 'Specifies the value of the Magento Contact field';
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Password Reset"; Rec."Password Reset")
                {
                    ToolTip = 'Specifies the value of the Password Reset field';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ToolTip = 'Specifies the value of the Error Message field';
                    ApplicationArea = All;
                    Editable = false;
                    Style = Attention;
                    StyleExpr = true;
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
                ApplicationArea = All;
                Image = Email;
                Caption = 'Reset Password Of Contacts';
                ToolTip = 'Reset Passwords of the Contacts';

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