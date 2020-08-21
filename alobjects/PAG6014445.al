page 6014445 "Create Credit Voucher"
{
    Caption = 'Create Credit Voucher';
    SourceTable = "Credit Voucher";

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
                    field("Post Code"; "Post Code")
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
                    field("No."; "No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Sales Ticket No."; "Sales Ticket No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Issue Date"; "Issue Date")
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
}

