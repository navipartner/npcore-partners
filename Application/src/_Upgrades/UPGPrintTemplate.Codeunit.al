codeunit 6150696 "NPR UPG Print Template"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeReceiptText();
    end;

    local procedure UpgradeReceiptText()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Print Template', 'OnUpgradePerCompany');
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Print Template", 'UpgradeReceiptText')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpgradePrintTemplateProcessingCU(6014550, 6014538, 'RECEIPT_TEXT', 'RECEIPT_TEXT', '', '');

        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Print Template", 'UpgradeReceiptText'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradePrintTemplateProcessingCU(FromProcessingCU: Integer; ToProcessingCU: Integer; FromProcessingFunctionID: Code[30]; ToProcessingFunctionId: Code[30]; FromProcessingFunctionParameter: Text[30]; ToProcessingFunctionParameter: Text[30])
    var
        RPTemplateLine: Record "NPR RP Template Line";
        RPTemplateHeader: Record "NPR RP Template Header";
    begin
        RPTemplateLine.SetRange("Processing Codeunit", FromProcessingCU);
        RPTemplateLine.SetRange("Processing Function ID", FromProcessingFunctionID);
        RPTemplateLine.SetRange("Processing Function Parameter", FromProcessingFunctionParameter);

        if RPTemplateLine.FindSet(true) then
            repeat
                if RPTemplateHeader.Get(RPTemplateLine."Template Code") then begin
                    if (RPTemplateHeader."Printer Type" = RPTemplateHeader."Printer Type"::Line) then begin
                        ArchiveVersionIfNecessary(RPTemplateLine."Template Code");
                        IncreaseVersionIfNecessary(RPTemplateLine."Template Code");
                        RPTemplateLine.Validate("Processing Codeunit", ToProcessingCU);
                        RPTemplateLine.Validate("Processing Function ID", ToProcessingFunctionId);
                        RPTemplateLine.Validate("Processing Function Parameter", ToProcessingFunctionParameter);
                        RPTemplateLine.Modify();

                        RPTemplateHeader.Get(RPTemplateLine."Template Code");
                        if not RPTemplateHeader.Archived then
                            RPTemplateHeader.Validate(Archived, true);
                    end
                end
            until RPTemplateLine.Next() = 0;
    end;

    local procedure ArchiveVersionIfNecessary(Template: Code[20])
    var
        RPTemplateHeader: Record "NPR RP Template Header";
        RPTemplateMgt: Codeunit "NPR RP Template Mgt.";
        Caption_AutoArchive: Label 'Auto archived version before upgrade', Locked = true;
    begin
        if RPTemplateHeader.Get(Template) then
            if not RPTemplateHeader.Archived then begin
                RPTemplateHeader."Version Comments" := Caption_AutoArchive;
                RPTemplateHeader."Version" := RPTemplateMgt.GetNextVersionNumber(RPTemplateHeader);
                RPTemplateHeader.Validate(Archived, true);
            end;
    end;

    local procedure IncreaseVersionIfNecessary(Template: Code[20])
    var
        RPTemplateHeader: Record "NPR RP Template Header";
        RPTemplateMgt: Codeunit "NPR RP Template Mgt.";
        Caption_AutoVersionBump: Label 'Auto created version for field upgrade', Locked = true;
    begin
        if RPTemplateHeader.Get(Template) then
            if RPTemplateHeader.Archived then begin
                RPTemplateMgt.CreateNewVersion(RPTemplateHeader);
                RPTemplateHeader."Version Comments" := Caption_AutoVersionBump;
                RPTemplateHeader.Modify(true);
            end;
    end;
}