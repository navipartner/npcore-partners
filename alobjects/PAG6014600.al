page 6014600 "Health Check Service"
{
    // NPR5.33/MMV /20170601 CASE 278908 Created page.
    // 
    // To use this health check, call the odata webservice with a filter on number and verify that you are getting the same number back in your response. Example:
    // Call URL: https://dev90.dynamics-retail.com:7088/NPRetail90_W1_DEV/OData/Company('MMV_test1')/health_check_service?$filter=Number%20eq%2042&$format=json
    // Verify: response JSON contains "Number" : 42.

    Caption = 'Health Check Service';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Integer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            field(Number;Number)
            {
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        i: Integer;
        ActiveSession: Record "Active Session";
        String: Text;
    begin
        if GetFilter(Number) <> '' then begin
          Evaluate(i, GetFilter(Number));

          Init;
          Number := i;
          Insert;
        end;
    end;
}

