codeunit 6150877 "NPR Upgrade Variety Setup"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Upgrade Variety Setup', 'OnUpgradePerCompany');

        EnablePopupFields();
        MoveVariantValueCodeToVarietyValue();

        LogMessageStopwatch.LogFinish();
    end;

    local procedure EnablePopupFields()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        VarietySetup: Record "NPR Variety Setup";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Upgrade Variety Setup', 'EnablePopupFields');

        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade Variety Setup")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        if VarietySetup.Get() and VarietySetup."Pop up Variety Matrix" then begin
            VarietySetup.SetPopupVarietyMatrixOnDocuments(true);
            VarietySetup.Modify();
        end;

        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade Variety Setup"));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure MoveVariantValueCodeToVarietyValue()
    var
        MagentoPictureLink: Record "NPR Magento Picture Link";
        MagentoSetup: Record "NPR Magento Setup";
        Item: Record Item;
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Upgrade Variety Setup', 'MoveVariantValueCodeToVarietyValue');

        if (UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade Variety Setup", 'MoveVariantValueCode'))) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        MagentoPictureLink.SetFilter("Variant Value Code", '<>%1', '');
        if MagentoPictureLink.IsEmpty() then
            exit;

        if not MagentoSetup.Get() then
            MagentoSetup.Init();

        MagentoPictureLink.FindSet();
        repeat
            if Item.Get(MagentoPictureLink."Item No.") then
                if MagentoSetup."Variant Picture Dimension" <> '' then begin
                    case MagentoSetup."Variant Picture Dimension" of
                        Item."NPR Variety 1":
                            begin
                                MagentoPictureLink."Variety Table" := Item."NPR Variety 1 Table";
                                MagentoPictureLink."Variety Type" := Item."NPR Variety 1";
                            end;
                        Item."NPR Variety 2":
                            begin
                                MagentoPictureLink."Variety Table" := Item."NPR Variety 2 Table";
                                MagentoPictureLink."Variety Type" := Item."NPR Variety 2";
                            end;
                        Item."NPR Variety 3":
                            begin
                                MagentoPictureLink."Variety Table" := Item."NPR Variety 3 Table";
                                MagentoPictureLink."Variety Type" := Item."NPR Variety 3";
                            end;
                        Item."NPR Variety 4":
                            begin
                                MagentoPictureLink."Variety Table" := Item."NPR Variety 4 Table";
                                MagentoPictureLink."Variety Type" := Item."NPR Variety 4";
                            end;
                    end;

                    MagentoPictureLink."Variety Value" := MagentoPictureLink."Variant Value Code";
                    MagentoPictureLink.Modify();
                end;
        until MagentoPictureLink.Next() = 0;

        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade Variety Setup", 'MoveVariantValueCode'));
        LogMessageStopwatch.LogFinish();
    end;
}