codeunit 6151359 "NPR POSAct: RV Set Tabl.Stat-B"
{
    Access = Internal;

    procedure SetSeatingStatus(SeatingCode: Code[20]; NewStatusCode: Code[10])
    var
        FlowStatus: Record "NPR NPRE Flow Status";
        SeatingMgt: Codeunit "NPR NPRE Seating Mgt.";
    begin
        if NewStatusCode = '' then
            exit;

        FlowStatus.SetRange("Status Object", FlowStatus."Status Object"::Seating);
        FlowStatus.SetRange(Code, NewStatusCode);
        FlowStatus.FindFirst();

        SeatingMgt.SetSeatingStatus(SeatingCode, FlowStatus.Code);
    end;
}