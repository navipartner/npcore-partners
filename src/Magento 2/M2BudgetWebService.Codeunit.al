codeunit 6151152 "NPR M2 Budget WebService"
{
    // NPR5.50/TSA /20190515 CASE 353714 Initial Version
    // MAG2.24/TSA /20191022 CASE 354183 Added Get Simple Budget


    trigger OnRun()
    begin
    end;

    procedure ListBudgets(var ListBudgets: XMLport "NPR M2 List Budgets")
    begin

        // NAV will run the EXPORT implicitly
    end;

    procedure GetBudgetDimensionValues(var GetBudgetDimensionValues: XMLport "NPR M2 Get Budget Dim. Values")
    begin

        SelectLatestVersion();

        GetBudgetDimensionValues.Import();
        GetBudgetDimensionValues.GenerateResponse();
    end;

    procedure GetBudgetData(var GetBudgetEntries: XMLport "NPR M2 Get Budget Entries")
    begin

        SelectLatestVersion();

        GetBudgetEntries.Import();
        GetBudgetEntries.GenerateResponse();
    end;

    procedure GetSimpleBudgetData(var GetSimpleBudget: XMLport "NPR M2 Get Simple Budget")
    begin

        //-MAG2.24 354183
        SelectLatestVersion();

        GetSimpleBudget.Import();
        GetSimpleBudget.GetRequest();
        GetSimpleBudget.CreateResponse();
        //+MAG2.24 354183
    end;
}

