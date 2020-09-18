page 6059775 "NPR Member Card Issued Cards"
{
    Caption = 'Point Card - Issued Cards';
    CardPageID = "NPR Member Card Iss. Card";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Member Card Issued Cards";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Customer No"; "Customer No")
                {
                    ApplicationArea = All;
                }
                field("Customer Type"; "Customer Type")
                {
                    ApplicationArea = All;
                }
                field("Issue Date"; "Issue Date")
                {
                    ApplicationArea = All;
                }
                field("Card Type"; "Card Type")
                {
                    ApplicationArea = All;
                }
                field(Salesperson; Salesperson)
                {
                    ApplicationArea = All;
                }
                field("Points (Total)"; "Points (Total)")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                }
                field("ZIP Code"; "ZIP Code")
                {
                    ApplicationArea = All;
                }
                field(City; City)
                {
                    ApplicationArea = All;
                }
                field("Valid Until"; "Valid Until")
                {
                    ApplicationArea = All;
                }
                field(Reference; Reference)
                {
                    ApplicationArea = All;
                }
                field("Canceling Salesperson"; "Canceling Salesperson")
                {
                    ApplicationArea = All;
                }
                field("Created in Company"; "Created in Company")
                {
                    ApplicationArea = All;
                }
                field("No. Printed"; "No. Printed")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        PointCardTypes: Record "NPR Member Card Types";
    begin

        PointCardTypes.Get("Card Type");
        SetFilter("Expiration Date Filter", '%1..%2', CalcDate(PointCardTypes."Expiration Calculation", Today), Today);
        CalcFields("Points (Total)");
    end;
}

