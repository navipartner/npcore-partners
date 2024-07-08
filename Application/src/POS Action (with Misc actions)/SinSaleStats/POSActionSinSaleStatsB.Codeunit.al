codeunit 6060098 "NPR POS Action: SinSaleStats-B"
{
    Access = Internal;
    procedure RunSingleSalesStatsPage()
    var
        POSEntry: Record "NPR POS Entry";
        POSSingleStatsBuffer: Record "NPR POS Single Stats Buffer";
        POSSession: Codeunit "NPR POS Session";
        POSStatisticsMgt: Codeunit "NPR POS Statistics Mgt.";
        POSUnitNo: Code[10];
    begin

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