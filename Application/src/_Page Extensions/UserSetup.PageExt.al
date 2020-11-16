pageextension 6014401 "NPR User Setup" extends "User Setup"
{
    layout
    {
        addafter("Time Sheet Admin.")
        {
            field("NPR Backoffice Register No."; "NPR Backoffice Register No.")
            {
                ApplicationArea = All;
            }
            field("NPR Allow Register Switch"; "NPR Allow Register Switch")
            {
                ApplicationArea = All;
            }
            field("NPR Register Switch Filter"; "NPR Register Switch Filter")
            {
                ApplicationArea = All;
            }
            field("NPR Backoffice Restaurant Code"; "NPR Backoffice Restaurant Code")
            {
                ApplicationArea = All;
            }
        }
        addafter(Email)
        {
            field("NPR Anonymize Customers"; "NPR Anonymize Customers")
            {
                ApplicationArea = All;
            }
            field("NPR Block Role Center"; "NPR Block Role Center")
            {
                ApplicationArea = All;
            }
        }
    }
}

