codeunit 6059909 "NPR TM Calendar Upgrade"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        MigrateTicketingCalendarChanges();
    end;

    local procedure MigrateTicketingCalendarChanges()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        if (UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR TM Calendar Upgrade"))) then
            exit;

        MigrateLocationCalendarChanges();
        MigrateServiceCalendarChanges();

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR TM Calendar Upgrade"));
    end;

    local procedure MigrateLocationCalendarChanges()
    var
        CustomizedCalendarChange: Record "Customized Calendar Change";
        CustomizedCalendarChange2: Record "Customized Calendar Change";
        Admission: Record "NPR TM Admission";
        Schedule: Record "NPR TM Admis. Schedule";
        AdmissionSchedule: Record "NPR TM Admis. Schedule Lines";
    begin
        CustomizedCalendarChange.SetFilter("Source Type", '=%1', CustomizedCalendarChange."Source Type"::Location);
        if (not CustomizedCalendarChange.FindSet(true)) then
            exit;

        repeat
            if ((CustomizedCalendarChange."Source Code" <> '') and (CustomizedCalendarChange."Additional Source Code" = '')) then begin
                if (Admission.Get(CustomizedCalendarChange."Source Code")) then begin
                    CustomizedCalendarChange2.TransferFields(CustomizedCalendarChange, true);
                    CustomizedCalendarChange2."Source Type" := CustomizedCalendarChange2."Source Type"::NPR_TM_Admission;
                    if (CustomizedCalendarChange2.Insert()) then
                        CustomizedCalendarChange.Delete();
                end;
            end;

            if ((CustomizedCalendarChange."Source Code" = '') and (CustomizedCalendarChange."Additional Source Code" <> '')) then begin
                if (Schedule.Get(CustomizedCalendarChange."Additional Source Code")) then begin
                    CustomizedCalendarChange2.TransferFields(CustomizedCalendarChange, true);
                    CustomizedCalendarChange2."Source Code" := CustomizedCalendarChange."Additional Source Code";
                    CustomizedCalendarChange2."Additional Source Code" := '';
                    CustomizedCalendarChange2."Source Type" := CustomizedCalendarChange2."Source Type"::NPR_TM_Schedule;
                    if (CustomizedCalendarChange2.Insert()) then
                        CustomizedCalendarChange.Delete();
                end;
            end;

            if ((CustomizedCalendarChange."Source Code" <> '') and (CustomizedCalendarChange."Additional Source Code" <> '')) then begin
                if (AdmissionSchedule.Get(CustomizedCalendarChange."Source Code", CustomizedCalendarChange."Additional Source Code")) then begin
                    CustomizedCalendarChange2.TransferFields(CustomizedCalendarChange, true);
                    CustomizedCalendarChange2."Source Type" := CustomizedCalendarChange2."Source Type"::NPR_TM_Admission_Schedule;
                    if (CustomizedCalendarChange2.Insert()) then
                        CustomizedCalendarChange.Delete();
                end;
            end;
        until (CustomizedCalendarChange.Next() = 0);
    end;

    local procedure MigrateServiceCalendarChanges()
    var
        CustomizedCalendarChange: Record "Customized Calendar Change";
        CustomizedCalendarChange2: Record "Customized Calendar Change";
        Admission: Record "NPR TM Admission";
        TicketBom: Record "NPR TM Ticket Admission BOM";
    begin
        CustomizedCalendarChange.SetFilter("Source Type", '=%1', CustomizedCalendarChange."Source Type"::Service);
        if (not CustomizedCalendarChange.FindSet(true)) then
            exit;

        repeat
            if ((CustomizedCalendarChange."Source Code" <> '') and (CustomizedCalendarChange."Additional Source Code" = '')) then begin
                if (Admission.Get(CustomizedCalendarChange."Source Code")) then begin
                    CustomizedCalendarChange2.TransferFields(CustomizedCalendarChange, true);
                    CustomizedCalendarChange2."Source Type" := CustomizedCalendarChange2."Source Type"::NPR_TM_BOM_Admission;
                    if (CustomizedCalendarChange2.Insert()) then
                        CustomizedCalendarChange.Delete();
                end;
            end;

            if ((CustomizedCalendarChange."Source Code" <> '') and (CustomizedCalendarChange."Additional Source Code" <> '')) then begin
                TicketBom.SetFilter("Item No.", '=%1', CustomizedCalendarChange."Additional Source Code");
                TicketBom.SetFilter("Admission Code", '=%1', CustomizedCalendarChange."Source Code");
                if (not TicketBom.IsEmpty()) then begin
                    CustomizedCalendarChange2.TransferFields(CustomizedCalendarChange, true);
                    CustomizedCalendarChange2."Source Type" := CustomizedCalendarChange2."Source Type"::NPR_TM_BOM_Admission_Item;
                    if (CustomizedCalendarChange2.Insert()) then
                        CustomizedCalendarChange.Delete();
                end;
            end;
        until (CustomizedCalendarChange.Next() = 0);
    end;

}