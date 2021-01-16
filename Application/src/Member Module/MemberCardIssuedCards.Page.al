page 6059775 "NPR Member Card Issued Cards"
{
    Caption = 'Point Card - Issued Cards';
    CardPageID = "NPR Member Card Iss. Card";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Customer No"; "Customer No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field("Customer Type"; "Customer Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer type field';
                }
                field("Issue Date"; "Issue Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Issue Date field';
                }
                field("Card Type"; "Card Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Point card type field';
                }
                field(Salesperson; Salesperson)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson field';
                }
                field("Points (Total)"; "Points (Total)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Points (Total) field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address field';
                }
                field("ZIP Code"; "ZIP Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ZIP Code field';
                }
                field(City; City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the City field';
                }
                field("Valid Until"; "Valid Until")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Valid Until field';
                }
                field(Reference; Reference)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference field';
                }
                field("Canceling Salesperson"; "Canceling Salesperson")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Canceling Salesperson field';
                }
                field("Created in Company"; "Created in Company")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created in Company field';
                }
                field("No. Printed"; "No. Printed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. Printed field';
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

