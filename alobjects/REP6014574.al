report 6014574 "Ret. Jnl. - Imp. Return Sales"
{
    Caption = 'Import Return Sales';
    ProcessingOnly = true;

    dataset
    {
        dataitem(RetailJournalHeader;"Retail Journal Header")
        {
            DataItemTableView = SORTING("No.");
        }
        dataitem(Register;Register)
        {
            DataItemTableView = SORTING("Register No.");
            RequestFilterFields = "Register No.","Location Code";
            dataitem(AuditRoll;"Audit Roll")
            {
                DataItemLink = "Register No."=FIELD("Register No.");
                DataItemTableView = SORTING("Register No.","Sale Type",Type,"No.","Sale Date","Discount Type","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code");
                RequestFilterFields = "Sale Date";

                trigger OnAfterGetRecord()
                begin
                    Clear(RetailJournalLine);
                    RetailJournalLine.Validate("No.", RetailJournalHeader."No.");
                    RetailJournalLine.Validate("Line No.", NextNo);
                    RetailJournalLine.Validate("Item No.", AuditRoll."No.");
                    RetailJournalLine.Validate("Quantity to Print", Abs(AuditRoll.Quantity));
                    RetailJournalLine.Validate("Calculation Date", AuditRoll."Sale Date");
                    RetailJournalLine.Validate("Location Filter", Register."Location Code");
                    RetailJournalLine.Insert(true);
                    NextNo += 10000;
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Sale Type", "Sale Type"::Sale);
                    SetRange(Type, Type::Item);
                    SetFilter(Quantity, '<%1', 0);

                    RetailJournalHeader.Get(RetailJournalHeader."No.");

                    Clear(RetailJournalLine);

                    RetailJournalLine.SetCurrentKey("No.", "Line No.");
                    RetailJournalLine.SetRange("No.", RetailJournalHeader."No.");

                    if RetailJournalLine.FindLast then
                      NextNo := RetailJournalLine."Line No." + 10000
                    else
                      NextNo := 10000;
                end;
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        RetailJournalLine: Record "Retail Journal Line";
        NextNo: Integer;
}

