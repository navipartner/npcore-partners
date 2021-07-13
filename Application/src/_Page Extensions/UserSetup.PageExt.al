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

                ToolTip = 'Specifies the value of the NPR Allow Register Switch field';
                ApplicationArea = NPRRetail;
            }
            field("NPR Register Switch Filter"; Rec."NPR Register Switch Filter")
            {

                ToolTip = 'Specifies the value of the NPR Register Switch Filter field';
                ApplicationArea = NPRRetail;
            }
            field("NPR Backoffice Restaurant Code"; Rec."NPR Backoffice Restaurant Code")
            {

                ToolTip = 'Specifies the value of the NPR Backoffice Restaurant Code field';
                ApplicationArea = NPRRetail;
            }
        }
        addafter(Email)
        {
            field("NPR Anonymize Customers"; Rec."NPR Anonymize Customers")
            {

                ToolTip = 'Specifies the value of the NPR Anonymize Customers field';
                ApplicationArea = NPRRetail;
            }
            field("NPR Block Role Center"; Rec."NPR Block Role Center")
            {

                ToolTip = 'Specifies the value of the NPR Block Role Center field';
                ApplicationArea = NPRRetail;
            }
        }
    }
}