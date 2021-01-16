page 6059774 "NPR Member Card Iss. Card"
{

    Caption = 'Point Card - Issued Card';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                        ToolTip = 'Specifies the value of the No. field';
                    }
                    field("Customer No"; "Customer No")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer No. field';
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
                    field(Status; Status)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Status field';
                    }
                    field(Reference; Reference)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Reference field';
                    }
                }
                group(Control6150624)
                {
                    ShowCaption = false;
                    field("Valid Until"; "Valid Until")
                    {
                        ApplicationArea = All;
                        Caption = 'Valid Until';
                        ToolTip = 'Specifies the value of the Valid Until field';
                    }
                    field("Points (Total)"; "Points (Total)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Points (Total) field';
                    }
                    field("Canceling Salesperson"; "Canceling Salesperson")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Canceling Salesperson field';
                    }
                    field("Created in Company"; "Created in Company")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Created in Company field';
                    }
                    field("Card Type"; "Card Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Point card type field';
                    }
                    field("Issue Date"; "Issue Date")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Issue Date field';
                    }
                    field(Salesperson; Salesperson)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Salesperson field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the List action';
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

