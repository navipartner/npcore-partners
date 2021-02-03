page 6014600 "NPR Health Check Service"
{
    // To use this health check, call the odata webservice with a filter on number and verify that you are getting the same number back in your response. Example:
    // Call URL: https://dev90.dynamics-retail.com:7088/NPRetail90_W1_DEV/OData/Company('MMV_test1')/health_check_service?$filter=Number%20eq%2042&$format=json
    // Verify: response JSON contains "Number" : 42.
    Caption = 'Health Check Service';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Integer";
    SourceTableTemporary = true;
    UsageCategory = Administration;
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            field(Number; Rec.Number)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Number field';
            }
        }
    }

    trigger OnOpenPage()
    var
        ActiveSession: Record "Active Session";
        i: Integer;
        String: Text;
    begin
        if Rec.GetFilter(Number) <> '' then begin
            Evaluate(i, Rec.GetFilter(Number));

            Rec.Init();
            Rec.Number := i;
            Rec.Insert();
        end;
    end;
}

