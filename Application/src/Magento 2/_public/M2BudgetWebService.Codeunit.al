codeunit 6151152 "NPR M2 Budget WebService"
{
#pragma warning disable AA0245
    procedure GetBudgetDimensionValues(var GetBudgetDimensionValues: XMLport "NPR M2 Get Budget Dim. Values")
    begin

        SelectLatestVersion();

        GetBudgetDimensionValues.Import();
        GetBudgetDimensionValues.GenerateResponse();
    end;
#pragma warning restore

    procedure GetBudgetData(var GetBudgetEntries: XMLport "NPR M2 Get Budget Entries")
    begin

        SelectLatestVersion();

        GetBudgetEntries.Import();
        GetBudgetEntries.GenerateResponse();
    end;

    procedure GetSimpleBudgetData(var GetSimpleBudget: XMLport "NPR M2 Get Simple Budget")
    begin
        SelectLatestVersion();

        GetSimpleBudget.Import();
        GetSimpleBudget.GetRequest();
        GetSimpleBudget.CreateResponse();
    end;
}

