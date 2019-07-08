codeunit 6151152 "M2 Budget WebService"
{
    // NPR5.50/TSA /20190515 CASE 353714 Initial Version


    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure ListBudgets(var ListBudgets: XMLport "M2 List Budgets")
    begin

        // NAV will run the EXPORT implicitly
    end;

    [Scope('Personalization')]
    procedure GetBudgetDimensionValues(var GetBudgetDimensionValues: XMLport "M2 Get Budget Dimension Values")
    begin

        SelectLatestVersion ();

        GetBudgetDimensionValues.Import ();
        GetBudgetDimensionValues.GenerateResponse ();
    end;

    [Scope('Personalization')]
    procedure GetBudgetData(var GetBudgetEntries: XMLport "M2 Get Budget Entries")
    begin

        SelectLatestVersion ();

        GetBudgetEntries.Import ();
        GetBudgetEntries.GenerateResponse ();
    end;
}

