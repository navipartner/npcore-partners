report 6014423 "NPR UPG RetDataMod AR Upgr."
{
    ProcessingOnly = true;
    Caption = 'UPG Retail Data Model A/R Upgrade';
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(ReportParameters)
                {
                    field(MaxNoOfRecords; MaxNoOfRecords)
                    {
                        Caption = 'Max No. of Records';
                        ToolTip = 'At least one parameter must be specified. Use "-1" to remove limitation.';
                        ApplicationArea = All;
                    }
                    field(MaxDuration; MaxDuration)
                    {
                        Caption = 'Max Duration (minutes)';
                        ToolTip = 'At least one parameter must be specified. Use "-1" to remove limitation.';
                        ApplicationArea = All;
                    }
                }
                group(AuditRollStats)
                {
                    field(AuditRollNoOfRecords; AuditRollNoOfRecords)
                    {
                        Caption = 'Total No. of Records';
                        Editable = false;
                        ApplicationArea = All;
                    }
                    field(AuditRollNoOfRecordsLeft; AuditRollNoOfRecordsLeft)
                    {
                        Caption = 'No. of Records left';
                        Editable = false;
                        ApplicationArea = All;
                    }
                }
            }
        }

        trigger OnOpenPage()
        var
            AuditRoll: Record "NPR Audit Roll";
            AuditRollToPOSEntryLink: Record "NPR Audit Roll 2 POSEntry Link";
        begin
            AuditRollNoOfRecords := AuditRoll.Count();
            AuditRollNoOfRecordsLeft := AuditRollNoOfRecords;
            if AuditRollToPOSEntryLink.FindLast() then begin
                AuditRoll.SetCurrentKey("Clustered Key");
                AuditRoll.SetFilter("Clustered Key", '>%1', AuditRolltoPOSEntryLink."Audit Roll Clustered Key");
                AuditRollNoOfRecordsLeft := AuditRoll.Count();
            end;
        end;
    }

    var
        MaxNoOfRecords, MaxDuration : Integer;
        RetailDataModelUpgrade: Codeunit "NPR UPG RetDataMod AR Upgr.";
        ParametersError: Label 'At least one parameter must be specified. Use "-1" to remove limitation.';
        ParameterValueError: Label 'Invalid parameter value.';

        AuditRollNoOfRecords: Integer;
        AuditRollNoOfRecordsLeft: Integer;

    trigger OnPreReport()
    begin
        if (MaxDuration = 0) and (MaxNoOfRecords = 0) then
            Error(ParametersError);
        if (MaxDuration < -1) or (MaxNoOfRecords < -1) then
            Error(ParameterValueError);
        RetailDataModelUpgrade.SetMaxNoOfRecords(MaxNoOfRecords);
        RetailDataModelUpgrade.SetMaxDuration(MaxDuration);
        RetailDataModelUpgrade.Run();
    end;

}