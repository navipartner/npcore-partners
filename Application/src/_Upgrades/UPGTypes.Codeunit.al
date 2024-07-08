codeunit 6151558 "NPR UPG Types"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Types', 'OnUpgradePerCompany');
        if not UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Types")) then begin
            UpdateTypes();
            UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Types"));
        end;
        if not UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Types", 'UpgradeKitcheRequests')) then begin
            UpgradeKitcheRequests();
            UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Types", 'UpgradeKitcheRequests'));
        end;
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateTypes()
    begin
        UpdateExternalPOSSale();
        UpdatePOSInfoTransaction();
        UpdatePOSSavedLine();
        UpdateWaiterPadLine();
    end;

    local procedure UpdateExternalPOSSale()
    var
        ExternalPOSSaleLine: Record "NPR External POS Sale Line";
    begin
        if ExternalPOSSaleLine.IsEmpty() then
            exit;
        ExternalPOSSaleLine.FindSet(true);
        repeat
            case ExternalPOSSaleLine.Type of
                ExternalPOSSaleLine.Type::"BOM List":
                    begin
                        ExternalPOSSaleLine."Line Type" := ExternalPOSSaleLine."Line Type"::"BOM List";
                        ExternalPOSSaleLine.Modify();
                    end;
                ExternalPOSSaleLine.Type::Comment:
                    begin
                        ExternalPOSSaleLine."Line Type" := ExternalPOSSaleLine."Line Type"::Comment;
                        ExternalPOSSaleLine.Modify();
                    end;
                ExternalPOSSaleLine.Type::Customer:
                    begin
                        ExternalPOSSaleLine."Line Type" := ExternalPOSSaleLine."Line Type"::"Customer Deposit";
                        ExternalPOSSaleLine.Modify();
                    end;
                ExternalPOSSaleLine.Type::"G/L Entry":
                    begin
                        ExternalPOSSaleLine."Line Type" := ExternalPOSSaleLine."Line Type"::"GL Payment";
                        ExternalPOSSaleLine.Modify();
                    end;
                ExternalPOSSaleLine.Type::Item:
                    begin
                        ExternalPOSSaleLine."Line Type" := ExternalPOSSaleLine."Line Type"::Item;
                        ExternalPOSSaleLine.Modify();
                    end;
                ExternalPOSSaleLine.Type::"Item Group":
                    begin
                        ExternalPOSSaleLine."Line Type" := ExternalPOSSaleLine."Line Type"::"Item Category";
                        ExternalPOSSaleLine.Modify();
                    end;
                ExternalPOSSaleLine.Type::Payment:
                    begin
                        ExternalPOSSaleLine."Line Type" := ExternalPOSSaleLine."Line Type"::"POS Payment";
                        ExternalPOSSaleLine.Modify();
                    end;
            end;
        until ExternalPOSSaleLine.Next() = 0;
    end;

    local procedure UpdatePOSInfoTransaction()
    var
        POSInfoTransaction: Record "NPR POS Info Transaction";
    begin
        if POSInfoTransaction.IsEmpty() then
            exit;
        POSInfoTransaction.FindSet(true);
        repeat
            case POSInfoTransaction."Receipt Type" of
                POSInfoTransaction."Receipt Type"::Comment:
                    begin
                        POSInfoTransaction."Line Type" := POSInfoTransaction."Line Type"::Comment;
                        POSInfoTransaction.Modify();
                    end;
                POSInfoTransaction."Receipt Type"::Customer:
                    begin
                        POSInfoTransaction."Line Type" := POSInfoTransaction."Line Type"::"Customer Deposit";
                        POSInfoTransaction.Modify();
                    end;
                POSInfoTransaction."Receipt Type"::"G/L":
                    begin
                        POSInfoTransaction."Line Type" := POSInfoTransaction."Line Type"::"GL Payment";
                        POSInfoTransaction.Modify();
                    end;
                POSInfoTransaction."Receipt Type"::Item:
                    begin
                        POSInfoTransaction."Line Type" := POSInfoTransaction."Line Type"::Item;
                        POSInfoTransaction.Modify();
                    end;
                POSInfoTransaction."Receipt Type"::Payment:
                    begin
                        POSInfoTransaction."Line Type" := POSInfoTransaction."Line Type"::"POS Payment";
                        POSInfoTransaction.Modify();
                    end;
            end;
        until POSInfoTransaction.Next() = 0;
    end;

    local procedure UpdatePOSSavedLine()
    var
        POSSavedSaleLine: Record "NPR POS Saved Sale Line";
    begin
        if POSSavedSaleLine.IsEmpty() then
            exit;
        POSSavedSaleLine.FindSet(true);
        repeat
            case POSSavedSaleLine.Type of
                POSSavedSaleLine.Type::"BOM List":
                    begin
                        POSSavedSaleLine."Line Type" := POSSavedSaleLine."Line Type"::"BOM List";
                        POSSavedSaleLine.Modify();
                    end;
                POSSavedSaleLine.Type::Comment:
                    begin
                        POSSavedSaleLine."Line Type" := POSSavedSaleLine."Line Type"::Comment;
                        POSSavedSaleLine.Modify();
                    end;
                POSSavedSaleLine.Type::Customer:
                    begin
                        POSSavedSaleLine."Line Type" := POSSavedSaleLine."Line Type"::"Customer Deposit";
                        POSSavedSaleLine.Modify();
                    end;
                POSSavedSaleLine.Type::"G/L Entry":
                    begin
                        POSSavedSaleLine."Line Type" := POSSavedSaleLine."Line Type"::"GL Payment";
                        POSSavedSaleLine.Modify();
                    end;
                POSSavedSaleLine.Type::Item:
                    begin
                        POSSavedSaleLine."Line Type" := POSSavedSaleLine."Line Type"::Item;
                        POSSavedSaleLine.Modify();
                    end;
                POSSavedSaleLine.Type::"Item Group":
                    begin
                        POSSavedSaleLine."Line Type" := POSSavedSaleLine."Line Type"::"Item Category";
                        POSSavedSaleLine.Modify();
                    end;
                POSSavedSaleLine.Type::Payment:
                    begin
                        POSSavedSaleLine."Line Type" := POSSavedSaleLine."Line Type"::"POS Payment";
                        POSSavedSaleLine.Modify();
                    end;
            end;
        until POSSavedSaleLine.Next() = 0;
    end;

    local procedure UpdateWaiterPadLine()
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        if WaiterPadLine.IsEmpty() then
            exit;
        WaiterPadLine.FindSet(true);
        repeat
            case WaiterPadLine.Type of
                WaiterPadLine.Type::"BOM List":
                    begin
                        WaiterPadLine."Line Type" := WaiterPadLine."Line Type"::"BOM List";
                        WaiterPadLine.Modify();
                    end;
                WaiterPadLine.Type::Comment:
                    begin
                        WaiterPadLine."Line Type" := WaiterPadLine."Line Type"::Comment;
                        WaiterPadLine.Modify();
                    end;
                WaiterPadLine.Type::Customer:
                    begin
                        WaiterPadLine."Line Type" := WaiterPadLine."Line Type"::"Customer Deposit";
                        WaiterPadLine.Modify();
                    end;
                WaiterPadLine.Type::"G/L Entry":
                    begin
                        WaiterPadLine."Line Type" := WaiterPadLine."Line Type"::"GL Payment";
                        WaiterPadLine.Modify();
                    end;
                WaiterPadLine.Type::Item:
                    begin
                        WaiterPadLine."Line Type" := WaiterPadLine."Line Type"::Item;
                        WaiterPadLine.Modify();
                    end;
                WaiterPadLine.Type::"Item Group":
                    begin
                        WaiterPadLine."Line Type" := WaiterPadLine."Line Type"::"Item Category";
                        WaiterPadLine.Modify();
                    end;
                WaiterPadLine.Type::Payment:
                    begin
                        WaiterPadLine."Line Type" := WaiterPadLine."Line Type"::"POS Payment";
                        WaiterPadLine.Modify();
                    end;
            end;
        until WaiterPadLine.Next() = 0;
    end;

    local procedure UpgradeKitcheRequests()
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
    begin
        if KitchenRequest.IsEmpty() then
            exit;
        KitchenRequest.FindSet(true);
        repeat
            case KitchenRequest.Type of
                KitchenRequest.Type::Item:
                    KitchenRequest."Line Type" := KitchenRequest."Line Type"::Item;
                KitchenRequest.Type::Comment:
                    KitchenRequest."Line Type" := KitchenRequest."Line Type"::Comment;
            end;
            KitchenRequest.Modify();
        until KitchenRequest.Next() = 0;
    end;
}
