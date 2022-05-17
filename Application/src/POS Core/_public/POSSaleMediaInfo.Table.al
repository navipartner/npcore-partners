table 6014681 "NPR POS Sale Media Info"
{
    Caption = 'POS Sale Media Info';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
            Editable = false;
        }
        field(3; "Register No."; Code[10])
        {
            Caption = 'Register No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; Image; Media)
        {
            Caption = 'Image';
            DataClassification = CustomerContent;
        }
        field(20; Comment; Text[100])
        {
            Caption = 'Comment';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(PosSales; "Register No.", "Sales Ticket No.")
        {
        }
    }

    procedure DeleteEntriesForPosSale(POSSale: Record "NPR POS Sale")
    var
        POSSaleMediaInfo: Record "NPR POS Sale Media Info";
    begin
        if POSSale.IsTemporary then
            exit;
        if (POSSale."Register No." = '') or (POSSale."Sales Ticket No." = '') then
            exit;
        POSSaleMediaInfo.SetCurrentKey("Register No.", "Sales Ticket No.");
        POSSaleMediaInfo.SetRange("Register No.", POSSale."Register No.");
        POSSaleMediaInfo.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        if POSSaleMediaInfo.IsEmpty then
            exit;
        POSSaleMediaInfo.DeleteAll(true);
    end;

    procedure TransferEntriesToPOSEntryMediaInfo(POSSale: Record "NPR POS Sale"; POSEntry: Record "NPR POS Entry"; DeleteTransfered: Boolean)
    var
        POSSaleMediaInfo: Record "NPR POS Sale Media Info";
        POSEntryMediaInfo: Record "NPR POS Entry Media Info";
    begin
        POSSaleMediaInfo.SetCurrentKey("Register No.", "Sales Ticket No.");
        POSSaleMediaInfo.SetRange("Register No.", POSSale."Register No.");
        POSSaleMediaInfo.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        if not POSSaleMediaInfo.FindSet() then
            exit;

        repeat
            POSEntryMediaInfo.Init();
            POSEntryMediaInfo.TransferFields(POSSaleMediaInfo, true, true);
            POSEntryMediaInfo."Entry No." := 0;
            POSEntryMediaInfo."Pos Entry No." := POSEntry."Entry No.";
            POSEntryMediaInfo.Insert(true);
        until POSSaleMediaInfo.Next() = 0;

        if DeleteTransfered then
            if POSSaleMediaInfo.FindSet() then
                POSSaleMediaInfo.DeleteAll(true);
    end;
}