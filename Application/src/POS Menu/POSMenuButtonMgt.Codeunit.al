codeunit 6150644 "NPR POS Menu Button Mgt."
{
    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnAfterActionUpdated', '', false, false)]
    local procedure OnAfterActionUpdated("Action": Record "NPR POS Action")
    var
        POSMenuButton: Record "NPR POS Menu Button";
    begin
        POSMenuButton.SetRange("Action Type", POSMenuButton."Action Type"::Action);
        POSMenuButton.SetRange("Action Code", Action.Code);
        if POSMenuButton.FindSet() then
            repeat
                if POSMenuButton.RefreshParametersRequired() then
                    POSMenuButton.RefreshParameters();
            until POSMenuButton.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Menu Button", 'OnAfterRenameEvent', '', false, false)]
    local procedure OnAfterPOSMenuButtonRename(var Rec: Record "NPR POS Menu Button"; var xRec: Record "NPR POS Menu Button"; RunTrigger: Boolean)
    var
        POSParameterValue: Record "NPR POS Parameter Value";
    begin
        if Rec.IsTemporary then
            exit;
        if not RunTrigger then
            exit;

        POSParameterValue.SetRange("Record ID", xRec.RecordId);
        if POSParameterValue.FindSet(true, true) then
            repeat
                POSParameterValue.Rename(POSParameterValue."Table No.", POSParameterValue.Code, POSParameterValue.ID, Rec.RecordId, POSParameterValue.Name);
            until POSParameterValue.Next() = 0;
    end;
}

