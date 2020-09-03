report 6151597 "NPR NpDc Request Priority"
{
    // NPR5.36/MHA /20170921  CASE 291016 Object created
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on ControlContainer Caption in Request Page
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL

    Caption = 'Request Priority';
    ProcessingOnly = true;

    dataset
    {
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Coupons)
                {
                    field(Priority; Priority)
                    {
                        Caption = 'Priority';
                        MinValue = 0;
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        CurrReport.Break;
    end;

    var
        Priority: Integer;

    procedure RequestPriority(var NewPriority: Integer): Boolean
    begin
        if CurrReport.RunRequestPage('') = '' then
            exit(false);

        NewPriority := Priority;
        exit(true);
    end;
}

