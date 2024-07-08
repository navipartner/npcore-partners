codeunit 6060031 "NPR POS Action: Lock POS B"
{
    Access = Internal;

    procedure LockPOS(Setup: Codeunit "NPR POS Setup")
    var
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSSession: Codeunit "NPR POS Session";
    begin
        POSSession.GetSetup(Setup);
        POSCreateEntry.InsertUnitLockEntry(Setup.GetPOSUnitNo(), Setup.Salesperson());

        POSSession.ChangeViewLocked();
    end;
}