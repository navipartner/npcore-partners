report 6014574 "NPR Ret. Jnl.: Imp. Ret. Sales"
{
    Caption = 'Import Return Sales';
    ProcessingOnly = true; 
    UsageCategory = ReportsAndAnalysis; 
    ApplicationArea = All;
    dataset
    {
        dataitem(RetailJournalHeader; "NPR Retail Journal Header")
        {
            DataItemTableView = SORTING("No.");
        }
        dataitem(Register; "NPR Register")
        {
            DataItemTableView = SORTING("Register No.");
            RequestFilterFields = "Register No.", "Location Code";
            dataitem(AuditRoll; "NPR Audit Roll")
            {
                DataItemLink = "Register No." = FIELD("Register No.");
                DataItemTableView = SORTING("Register No.", "Sale Type", Type, "No.", "Sale Date", "Discount Type", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
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
                    if RetailJournalLine.FindLast() then
                        NextNo := RetailJournalLine."Line No." + 10000
                    else
                        NextNo := 10000;
                end;
            }
        }
    }

    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        NextNo: Integer;
}

