page 6059774 "NPR Member Card Iss. Card"
{
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer

    Caption = 'Point Card - Issued Card';
    PageType = Card;
    SourceTable = "NPR Member Card Issued Cards";

    layout
    {
        area(content)
        {
            grid(General)
            {
                group(Control6150615)
                {
                    ShowCaption = false;
                    field("No."; "No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("Customer No"; "Customer No")
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
                    field(Status; Status)
                    {
                        ApplicationArea = All;
                    }
                    field(Reference; Reference)
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control6150624)
                {
                    ShowCaption = false;
                    field("Valid Until"; "Valid Until")
                    {
                        ApplicationArea = All;
                        Caption = 'Valid Until';
                    }
                    field("Points (Total)"; "Points (Total)")
                    {
                        ApplicationArea = All;
                    }
                    field("Canceling Salesperson"; "Canceling Salesperson")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("Created in Company"; "Created in Company")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("Card Type"; "Card Type")
                    {
                        ApplicationArea = All;
                    }
                    field("Issue Date"; "Issue Date")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field(Salesperson; Salesperson)
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(List)
            {
                Caption = 'List';
                Image = List;
                RunObject = Page "NPR Member Card Issued Cards";
            }
        }
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

