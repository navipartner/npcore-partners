report 6151597 "NPR NpDc Request Priority"
{
    #IF NOT BC17 
    Extensible = False; 
    #ENDIF
    Caption = 'Request Priority';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(Coupons)
                {
                    field("Priority field"; Priority)
                    {
                        Caption = 'Priority';
                        MinValue = 0;
                        ToolTip = 'Specifies the value of the Priority field';
                        ApplicationArea = NPRRetail;
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

