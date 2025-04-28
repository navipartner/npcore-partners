table 6151043 "NPR HU L Cash Mgt. Reason"
{
    Access = Internal;
    Caption = 'HU Laurel Cash Mgt Reason';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR HU L Cash Mgt. Reasons";
    LookupPageId = "NPR HU L Cash Mgt. Reasons";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Cash Mgt Reason"; Enum "NPR HU L Cash Mgt. Reason")
        {
            Caption = 'Cash Mgt. Reason';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.") { }
    }

    internal procedure InitCashMgtReasons()
    var
        HULCashMgtReason: Record "NPR HU L Cash Mgt. Reason";
        i: Integer;
    begin
        HULCashMgtReason.DeleteAll();

        for i := 1 to 7 do begin
            HULCashMgtReason.Init();
            HULCashMgtReason."Entry No." := i;
            HULCashMgtReason."Cash Mgt Reason" := Enum::"NPR HU L Cash Mgt. Reason".FromInteger(i);
            HULCashMgtReason.Insert();
        end;

        for i := 31 to 40 do begin
            HULCashMgtReason.Init();
            HULCashMgtReason."Entry No." := i;
            HULCashMgtReason."Cash Mgt Reason" := Enum::"NPR HU L Cash Mgt. Reason".FromInteger(i);
            HULCashMgtReason.Insert();
        end;
    end;
}