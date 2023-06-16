codeunit 6150696 "NPR UPG Print Template"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeReceiptText();
        UpgradeRJLVendorFields();
        UpgradeLogoAlignment();
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

    local procedure UpgradeRJLVendorFields()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Print Template', 'OnUpgradePerCompany');
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Print Template", 'UpgradeRJLVendorFields')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpgradePrintTemplateRJLVendorFields();

        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Print Template", 'UpgradeRJLVendorFields'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradeLogoAlignment()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Print Template', 'OnUpgradePerCompany');
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Print Template", 'UpgradeLogoAlignment')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpgradePrintTemplateLogoAlignment();

        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Print Template", 'UpgradeLogoAlignment'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradePrintTemplateLogoAlignment()
    var
        RPTemplateLine: Record "NPR RP Template Line";
        RPTemplateLine2: Record "NPR RP Template Line";
        RPTemplateHeader: Record "NPR RP Template Header";
        TemplateCode: Code[20];
    begin
        RPTemplateLine.SetRange(Type, RPTemplateLine.Type::Logo);
        RPTemplateLine.SetFilter(Align, '<>%1', RPTemplateLine.Align::Left);
        if RPTemplateLine.FindSet() then
            repeat
                if TemplateCode <> RPTemplateLine."Template Code" then begin
                    TemplateCode := RPTemplateLine."Template Code";

                    if RPTemplateHeader.Get(RPTemplateLine."Template Code") then begin
                        ArchiveVersionIfNecessary(RPTemplateLine."Template Code");
                        IncreaseVersionIfNecessary(RPTemplateLine."Template Code");

                        RPTemplateLine2.SetRange("Template Code", RPTemplateLine."Template Code");
                        RPTemplateLine2.SetRange(Type, RPTemplateLine.Type::Logo);
                        RPTemplateLine2.SetFilter(Align, '<>%1', RPTemplateLine.Align::Left);

                        if RPTemplateLine2.FindSet(true) then
                            repeat
                                RPTemplateLine2.Align := RPTemplateLine2.Align::Left;
                                RPTemplateLine2.Modify();
                            until RPTemplateLine2.Next() = 0;

                        ArchiveVersionIfNecessary(RPTemplateLine."Template Code");
                    end;
                end;
            until RPTemplateLine.Next() = 0;
    end;

    local procedure UpgradePrintTemplateRJLVendorFields()
    var
        RPTemplateLine: Record "NPR RP Template Line";
        RPTemplateLine2: Record "NPR RP Template Line";
        RPTemplateHeader: Record "NPR RP Template Header";
        TemplateCode: Code[20];
    begin
        RPTemplateLine.SetRange("Data Item Table", 6014422);
        RPTemplateLine.SetFilter(Field, '%1|%2|%3', 6, 41, 42);
        if RPTemplateLine.FindSet() then
            repeat
                if TemplateCode <> RPTemplateLine."Template Code" then begin
                    TemplateCode := RPTemplateLine."Template Code";

                    if RPTemplateHeader.Get(RPTemplateLine."Template Code") then begin
                        ArchiveVersionIfNecessary(RPTemplateLine."Template Code");
                        IncreaseVersionIfNecessary(RPTemplateLine."Template Code");

                        RPTemplateLine2.SetRange("Template Code", RPTemplateLine."Template Code");
                        RPTemplateLine2.SetRange("Data Item Table", 6014422);
                        RPTemplateLine2.SetFilter(Field, '%1|%2|%3', 6, 41, 42);

                        if RPTemplateLine2.FindSet(true) then
                            repeat
                                case RPTemplateLine2.Field of
                                    6:
                                        RPTemplateLine2.Validate(Field, 15);
                                    41:
                                        RPTemplateLine2.Validate(Field, 43);
                                    42:
                                        RPTemplateLine2.Validate(Field, 44);
                                end;
                                RPTemplateLine2.Modify();
                            until RPTemplateLine2.Next() = 0;

                        ArchiveVersionIfNecessary(RPTemplateLine."Template Code");
                    end;
                end;
            until RPTemplateLine.Next() = 0;
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

                        ArchiveVersionIfNecessary(RPTemplateLine."Template Code");
                    end;
                end;
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
                RPTemplateHeader."Version" := CopyStr(RPTemplateMgt.GetNextVersionNumber(RPTemplateHeader), 1, MaxStrLen(RPTemplateHeader."Version"));
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