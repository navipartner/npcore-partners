codeunit 6150644 "NPR POS Menu Button Mgt."
{
    [EventSubscriber(ObjectType::Table, 6150703, 'OnAfterActionUpdated', '', false, false)]
    local procedure OnAfterActionUpdated("Action": Record "NPR POS Action")
    var
        POSMenuButton: Record "NPR POS Menu Button";
    begin
        POSMenuButton.SetRange("Action Type", POSMenuButton."Action Type"::Action);
        POSMenuButton.SetRange("Action Code", Action.Code);
        if POSMenuButton.FindSet then
            repeat
                if POSMenuButton.RefreshParametersRequired() then
                    POSMenuButton.RefreshParameters();
            until POSMenuButton.Next = 0;
    end;

    [EventSubscriber(ObjectType::Table, 6150701, 'OnAfterRenameEvent', '', false, false)]
    local procedure OnAfterPOSMenuButtonRename(var Rec: Record "NPR POS Menu Button"; var xRec: Record "NPR POS Menu Button"; RunTrigger: Boolean)
    var
        POSParameterValue: Record "NPR POS Parameter Value";
    begin
        if Rec.IsTemporary then
            exit;
        if not RunTrigger then
            exit;

        with POSParameterValue do begin
            SetRange("Record ID", xRec.RecordId);
            if FindSet(true, true) then
                repeat
                    Rename("Table No.", Code, ID, Rec.RecordId, Name);
                until POSParameterValue.Next = 0;
        end;
    end;
}

