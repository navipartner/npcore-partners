codeunit 6184677 "NPR Ref.No. Assignment-Default" implements "NPR Reference No. Assignment"
{
    Access = Internal;

    procedure GetReferenceNo(POSEndofDayProfile: Record "NPR POS End of Day Profile"; RefNoTarget: Enum "NPR Reference No. Target"; Parameters: Dictionary of [Text, Text]): Text[50]
    begin
        exit('');
    end;
}