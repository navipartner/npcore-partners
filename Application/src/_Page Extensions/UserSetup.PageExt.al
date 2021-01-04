pageextension 6014401 "NPR User Setup" extends "User Setup"
{
    layout
    {
        addafter("Time Sheet Admin.")
        {
            field("NPR Backoffice Register No."; "NPR Backoffice Register No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Backoffice Register No. field';
            }
            field("NPR Allow Register Switch"; "NPR Allow Register Switch")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Allow Register Switch field';
            }
            field("NPR Register Switch Filter"; "NPR Register Switch Filter")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Register Switch Filter field';
            }
            field("NPR Backoffice Restaurant Code"; "NPR Backoffice Restaurant Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Backoffice Restaurant Code field';
            }
        }
        addafter(Email)
        {
            field("NPR Anonymize Customers"; "NPR Anonymize Customers")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Anonymize Customers field';
            }
            field("NPR Block Role Center"; "NPR Block Role Center")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Block Role Center field';
            }
        }
    }
}

