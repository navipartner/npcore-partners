report 6151597 "NPR NpDc Request Priority"
{
    Caption = 'Request Priority';
    ProcessingOnly = true;
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
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Priority field';
                    }
                }
            }
        }

    }


    trigger OnPreReport()
    begin
        CurrReport.Break();
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

