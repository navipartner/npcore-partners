codeunit 6059816 "NPR POS Action: Sin Sale Stats"
{
    Access = Internal;
    local procedure ActionCode(): Text[20]
    begin
        exit('SINGLE_SALE_STATS');
    end;

    local procedure ActionVersion(): Code[10]
    begin

        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    var
        ActionDescription: Label 'This built-in action opens page with single sale statistics.';
    begin
        if Sender.DiscoverAction20(ActionCode(), ActionDescription, ActionVersion()) then begin
            Sender.RegisterWorkflow20('await workflow.respond();');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSUnitNo: Code[10];
        POSEntry: Record "NPR POS Entry";
        POSSingleStatsBuffer: Record "NPR POS Single Stats Buffer";
        POSStatisticsMgt: Codeunit "NPR POS Statistics Mgt.";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        POSUnitNo := GetPOSUnit(POSSession);

        if POSStatisticsMgt.TryGetPOSEntry(POSEntry, POSUnitNo) then begin
            POSStatisticsMgt.FillSingleStatsBuffer(POSSingleStatsBuffer, POSEntry);

            Page.Run(Page::"NPR POS Single Sale Statistics", POSSingleStatsBuffer);
        end;
    end;

    local procedure GetPOSUnit(POSSession: Codeunit "NPR POS Session"): Code[10]
    var
        POSSetup: Codeunit "NPR POS Setup";
    begin
        POSSession.GetSetup(POSSetup);
        exit(POSSetup.GetPOSUnitNo());
    end;
}