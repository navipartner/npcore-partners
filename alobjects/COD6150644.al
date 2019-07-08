codeunit 6150644 "POS Menu Button Mgt."
{
    // NPR5.40/MMV /20180307 CASE 307453 Created object
    // NPR5.44/MMV /20180627 CASE 320850 Handle parameters when menus are renamed


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnAfterActionUpdated', '', false, false)]
    local procedure OnAfterActionUpdated("Action": Record "POS Action")
    var
        POSMenuButton: Record "POS Menu Button";
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
    local procedure OnAfterPOSMenuButtonRename(var Rec: Record "POS Menu Button";var xRec: Record "POS Menu Button";RunTrigger: Boolean)
    var
        POSParameterValue: Record "POS Parameter Value";
    begin
        //-NPR5.44 [320850]
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
        //+NPR5.44 [320850]
    end;
}

