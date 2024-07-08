codeunit 6150962 "NPR Event Public Access"
{
    procedure UpdateCurrentEvent(POSSale: Codeunit "NPR POS Sale"; EventNo: Code[20]; UpdateRegister: Boolean)
    var
        POSActChgActvEventBL: Codeunit "NPR POS Act:Chg.Actv.Event BL";
    begin
        POSActChgActvEventBL.UpdateCurrentEvent(POSSale, EventNo, UpdateRegister);
    end;
}