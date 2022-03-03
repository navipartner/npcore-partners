pageextension 6014401 "NPR User Setup" extends "User Setup"
{
    layout
    {
        addafter("Time Sheet Admin.")
        {
            field("NPR POS Unit No."; Rec."NPR POS Unit No.")
            {

                ToolTip = 'The POS Unit that the user logs onto in the POS';
                ApplicationArea = NPRRetail;
            }
            field("NPR Allow Register Switch"; Rec."NPR Allow Register Switch")
            {

                ToolTip = 'Specifies if the user is allowed to switch between registers.';
                ApplicationArea = NPRRetail;
            }
            field("NPR Register Switch Filter"; Rec."NPR Register Switch Filter")
            {

                ToolTip = 'Specifies the list of registers the user is allowed to switch between.';
                ApplicationArea = NPRRetail;
            }
            field("NPR Backoffice Restaurant Code"; Rec."NPR Backoffice Restaurant Code")
            {

                ToolTip = 'Specifies the Backoffice Restaurant Code for the user.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter(Email)
        {
            field("NPR Anonymize Customers"; Rec."NPR Anonymize Customers")
            {

                ToolTip = 'Specifies if the user is allowed to anonymize customer information in the customer page.';
                ApplicationArea = NPRRetail;
            }
            field("NPR MM Allow MS Entry Edit"; Rec."NPR MM Allow MS Entry Edit")
            {
                ToolTip = 'Specifies if the user can modify Membership Entries.';
                ApplicationArea = NPRRetail;
            }

        }
    }
}