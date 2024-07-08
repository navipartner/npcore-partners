interface "NPR Reference No. Assignment"
{
    procedure GetReferenceNo(POSEndofDayProfile: Record "NPR POS End of Day Profile"; RefNoTarget: Enum "NPR Reference No. Target"; Parameters: Dictionary of [Text, Text]): Text[50]
}