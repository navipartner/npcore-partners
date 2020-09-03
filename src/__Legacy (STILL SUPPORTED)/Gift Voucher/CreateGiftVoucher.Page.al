page 6014446 "NPR Create Gift Voucher"
{
    Caption = 'Create Gift Voucher';
    SourceTable = "NPR Gift Voucher";

    layout
    {
        area(content)
        {
            grid(Control6150613)
            {
                ShowCaption = false;
                group(Control6150615)
                {
                    ShowCaption = false;
                    field(Amount; Amount)
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
                }
                group(Control6150621)
                {
                    ShowCaption = false;
                    field("Issue Date"; "Issue Date")
                    {
                        ApplicationArea = All;
                    }
                    field("No."; "No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Sales Ticket No."; "Sales Ticket No.")
                    {
                        ApplicationArea = All;
                    }
                    field(Salesperson; Salesperson)
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
    }

    actions
    {
    }

    var
        Text10600000: Label 'Amount must be more than 0';
}

