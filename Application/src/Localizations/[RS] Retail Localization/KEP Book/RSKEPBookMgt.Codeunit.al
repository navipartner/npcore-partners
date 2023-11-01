codeunit 6184586 "NPR RS KEP Book Mgt."
{
    Access = Internal;

    internal procedure CreateKEPBookDataset(var KEPBook: Record "NPR RS KEP Book" temporary; LocationCode: Code[10]; YearFilter: Integer)
    var
        KEPBookDataset: Query "NPR RS KEP Book Dataset";
    begin
        if not KEPBook.IsEmpty() then
            KEPBook.DeleteAll();

        KEPBookDataset.SetRange(Location_Code, LocationCode);
        KEPBookDataset.SetRange(Posting_Date, DMY2Date(1, 1, YearFilter), DMY2Date(31, 12, YearFilter));

        KEPBookDataset.Open();

        while KEPBookDataset.Read() do begin
            KEPBook.Init();
            KEPBook."Entry No." := KEPBook."Entry No." + 1;
            KEPBook."Source Entry No." := KEPBookDataset.Entry_No;
            KEPBook."Location Code" := KEPBookDataset.Location_Code;
            KEPBook."Document Date" := KEPBookDataset.Document_Date;
            KEPBook."Posting Date" := KEPBookDataset.Posting_Date;
            KEPBook."Document No." := KEPBookDataset.Document_No;
            KEPBook.Year := Date2DMY(KEPBookDataset.Posting_Date, 3);
            KEPBook."Document Type" := KEPBookDataset.Document_Type;
            KEPBook."Source No." := KEPBookDataset.Source_No;
            KEPBook.Description := StrSubstNo('%1 %2 %3', KEPBookDataset.Document_Type, KEPBookDataset.Document_No, KEPBookDataset.Document_Date);
            KEPBook."Credit Amount" := KEPBookDataset.Sales_Amount_Actual;
            KEPBook."Debit Amount" := KEPBookDataset.Cost_Amount_Actual;
            KEPBook.Insert();
        end;

        KEPBookDataset.Close();
    end;

    internal procedure GetStartBalanceAmounts(var DebitAmount: Decimal; var CreditAmount: Decimal; LocationCode: Code[10]; YearFilter: Integer)
    var
        KEPBookDataset: Query "NPR RS KEP Book Dataset";
    begin
        Clear(DebitAmount);
        Clear(CreditAmount);

        KEPBookDataset.SetRange(Location_Code, LocationCode);
        KEPBookDataset.SetRange(Posting_Date, DMY2Date(1, 1, YearFilter), DMY2Date(31, 12, YearFilter));

        KEPBookDataset.Open();

        while KEPBookDataset.Read() do begin
            CreditAmount += KEPBookDataset.Sales_Amount_Actual;
            DebitAmount += KEPBookDataset.Cost_Amount_Actual;
        end;

        KEPBookDataset.Close();
    end;
}