﻿codeunit 6151152 "NPR M2 Budget WebService"
{
    procedure GetBudgetDimensionValues(var GetBudgetDimValuesXmlPort: XMLport "NPR M2 Get Budget Dim. Values")
    begin

        SelectLatestVersion();

        GetBudgetDimValuesXmlPort.Import();
        GetBudgetDimValuesXmlPort.GenerateResponse();
    end;

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

