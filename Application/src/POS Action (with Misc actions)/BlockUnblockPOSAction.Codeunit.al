codeunit 6014691 "NPR Block/Unblock POS Action"
{
    Access = Internal;
    TableNo = "NPR POS Action";

    trigger OnRun()
    var
        POSAction: Record "NPR POS Action";
        POSAction2: Record "NPR POS Action";
        Handled: Boolean;
    begin
        POSAction.Copy(Rec);
        if POSAction.FindSet(true) then
            repeat
                POSAction2 := POSAction;
                Handled := false;
                OnBeforePosActionToggleBlocked(POSAction2, Handled);
                if not Handled then begin
                    POSAction2.Validate(Blocked, not POSAction2.Blocked);
                    POSAction2.Modify();
                end;
            until POSAction.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePosActionToggleBlocked(var POSAction: Record "NPR POS Action"; var Handled: Boolean)
    begin
    end;
}
