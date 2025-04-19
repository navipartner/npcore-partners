report 6014559 "NPR Ext JQ Refresher Entra App"
{
#if not BC17
    Extensible = False;
#endif
    Caption = 'Create new Job Queue Runner User';
    UsageCategory = none;
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field(AppDisplayName; _AppDisplayName)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'User Name';
                        ToolTip = 'Specifies the user name of the desired Job Queue Refresher Runner.';
                        NotBlank = true;
                    }
                }
            }
        }
    }

    procedure RequestAppDisplayName(): Text
    begin
        if CurrReport.RunRequestPage() = '' then
            exit('');
        exit(_AppDisplayName);
    end;

    var
        _AppDisplayName: Text[50];
}
