codeunit 6150999 "NPR UPG Pos Entry Dims"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Pos Entry Dims', 'OnUpgradePerCompany');

        if not UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Pos Entry Dims", '20230515')) then begin
            FixMissingPOSEntryLineDimensions();
            UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Pos Entry Dims", '20230515'));
        end;
        LogMessageStopwatch.LogFinish();
    end;

    local procedure FixMissingPOSEntryLineDimensions()
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSEntry.SetCurrentKey("Post Item Entry Status");
        POSEntry.SetRange("Post Item Entry Status", POSEntry."Post Item Entry Status"::Unposted, POSEntry."Post Item Entry Status"::"Error while Posting");
        if POSEntry.FindSet() then
            repeat
                POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                if POSEntrySalesLine.FindSet() then
                    repeat
                        if (POSEntrySalesLine."Dimension Set ID" = 0) and (POSEntry."Dimension Set ID" <> 0) then begin
                            POSEntrySalesLine."Shortcut Dimension 1 Code" := POSEntry."Shortcut Dimension 1 Code";
                            POSEntrySalesLine."Shortcut Dimension 2 Code" := POSEntry."Shortcut Dimension 2 Code";
                            POSEntrySalesLine."Dimension Set ID" := POSEntry."Dimension Set ID";
                            POSEntrySalesLine.Modify();
                        end;
                    until POSEntrySalesLine.Next() = 0;
            until POSEntry.Next() = 0;

        POSEntry.Reset();
        POSEntry.SetCurrentKey("Post Entry Status");
        POSEntry.SetRange("Post Entry Status", POSEntry."Post Entry Status"::Unposted, POSEntry."Post Entry Status"::"Error while Posting");
        if POSEntry.FindSet() then
            repeat
                POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                if POSEntryPaymentLine.FindSet() then
                    repeat
                        if (POSEntryPaymentLine."Dimension Set ID" = 0) and (POSEntry."Dimension Set ID" <> 0) then begin
                            POSEntryPaymentLine."Shortcut Dimension 1 Code" := POSEntry."Shortcut Dimension 1 Code";
                            POSEntryPaymentLine."Shortcut Dimension 2 Code" := POSEntry."Shortcut Dimension 2 Code";
                            POSEntryPaymentLine."Dimension Set ID" := POSEntry."Dimension Set ID";
                            POSEntryPaymentLine.Modify();
                        end;
                    until POSEntryPaymentLine.Next() = 0;
            until POSEntry.Next() = 0;
    end;
}