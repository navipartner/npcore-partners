page 6014446 "Create Gift Voucher"
{
    Caption = 'Create Gift Voucher';
    SourceTable = "Gift Voucher";

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
                    field(Amount;Amount)
                    {
                    }
                    field(Name;Name)
                    {
                    }
                    field(Address;Address)
                    {
                    }
                    field("ZIP Code";"ZIP Code")
                    {
                    }
                    field(City;City)
                    {
                    }
                }
                group(Control6150621)
                {
                    ShowCaption = false;
                    field("Issue Date";"Issue Date")
                    {
                    }
                    field("No.";"No.")
                    {
                    }
                    field("Sales Ticket No.";"Sales Ticket No.")
                    {
                    }
                    field(Salesperson;Salesperson)
                    {
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

