pageextension 6014401 "NPR User Setup" extends "User Setup"
{
    layout
    {
        addafter("Time Sheet Admin.")
        {
            field("NPR POS Unit No."; Rec."NPR POS Unit No.")
            {
                ApplicationArea = All;
                ToolTip = 'The POS Unit that the user logs onto in the POS';
            }
            field("NPR Allow Register Switch"; Rec."NPR Allow Register Switch")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Allow Register Switch field';
            }
            field("NPR Register Switch Filter"; Rec."NPR Register Switch Filter")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Register Switch Filter field';
            }
            field("NPR Backoffice Restaurant Code"; Rec."NPR Backoffice Restaurant Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Backoffice Restaurant Code field';
            }
        }
        addafter(Email)
        {
            field("NPR Anonymize Customers"; Rec."NPR Anonymize Customers")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Anonymize Customers field';
            }
            field("NPR Block Role Center"; Rec."NPR Block Role Center")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Block Role Center field';
            }
        }
    }
}