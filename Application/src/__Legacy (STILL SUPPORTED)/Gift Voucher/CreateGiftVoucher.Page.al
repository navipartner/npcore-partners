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
                        ToolTip = 'Specifies the value of the Amount field';
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
                }
                group(Control6150621)
                {
                    ShowCaption = false;
                    field("Issue Date"; "Issue Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Issue Date field';
                    }
                    field("No."; "No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the No. field';
                    }
                    field("Sales Ticket No."; "Sales Ticket No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sales Ticket No. field';
                    }
                    field("Salesperson Code"; "Salesperson Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Salesperson Code field';
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

