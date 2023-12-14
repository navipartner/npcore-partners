codeunit 6184678 "NPR Ref.No. Assignment-Auto" implements "NPR Reference No. Assignment"
{
    Access = Internal;

    procedure GetReferenceNo(POSEndofDayProfile: Record "NPR POS End of Day Profile"; RefNoTarget: Enum "NPR Reference No. Target"; Parameters: Dictionary of [Text, Text]): Text[50]
    var
        RefNoAssignmentHelper: Codeunit "NPR Ref.No. Assignment Helper";
        POSPmtMethodCode: Text;
        POSUnitCode: Text;
        ReferenceNo: Text;
    begin
        case RefNoTarget of
            RefNoTarget::EOD_BankDeposit,
            RefNoTarget::BT_OUT_BankDeposit:
                ReferenceNo := 'DEP';
            RefNoTarget::EOD_MoveToBin,
            RefNoTarget::BT_OUT_MoveToBin:
                ReferenceNo := 'TX';
            RefNoTarget::BT_IN_FromBank:
                ReferenceNo := 'FB';
            RefNoTarget::BT_IN_FromBin:
                ReferenceNo := 'FX';
            else
                exit('');
        end;
        if Parameters.ContainsKey(RefNoAssignmentHelper.PosUnitNoParam()) then
            Parameters.Get(RefNoAssignmentHelper.PosUnitNoParam(), POSUnitCode);
        if Parameters.ContainsKey(RefNoAssignmentHelper.PosPmtMethodCodeParam()) then
            Parameters.Get(RefNoAssignmentHelper.PosPmtMethodCodeParam(), POSPmtMethodCode);
        ReferenceNo := StrSubstNo('%1-%2-%3-%4', ReferenceNo, POSUnitCode, POSPmtMethodCode, Format(CurrentDateTime(), 0, 9));
        exit(CopyStr(ReferenceNo, 1, 50));
    end;
}