table 6014475 "NPR Retail Price Log Setup"
{
    // NPR5.40/MHA /20180316  CASE 304031 Object created
    // NPR5.48/MHA /20181102  CASE 334573 Replaced 90 Days InitValue on field 15 "Delete Price Log Entries after" with function InitDeletePriceLogEntriesAfter()

    Caption = 'Retail Unit Price Log Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(5; "Price Log Activated"; Boolean)
        {
            Caption = 'Price Log Activated';
            DataClassification = CustomerContent;
        }
        field(10; "Task Queue Activated"; Boolean)
        {
            Caption = 'Task Queue Activated';
            DataClassification = CustomerContent;
        }
        field(15; "Delete Price Log Entries after"; Duration)
        {
            Caption = 'Delete Price Log Entries after';
            Description = 'NPR5.48';
            DataClassification = CustomerContent;
        }
        field(100; "Item Unit Price"; Boolean)
        {
            Caption = 'Item Unit Price';
            DataClassification = CustomerContent;
        }
        field(105; "Sales Price"; Boolean)
        {
            Caption = 'Sales Price';
            DataClassification = CustomerContent;
        }
        field(110; "Sales Line Discount"; Boolean)
        {
            Caption = 'Sales Line Discount';
            DataClassification = CustomerContent;
        }
        field(120; "Period Discount"; Boolean)
        {
            Caption = 'Period Discount';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        //-NPR5.48 [334573]
        InitDeletePriceLogEntriesAfter();
        //+NPR5.48 [334573]
    end;

    local procedure InitDeletePriceLogEntriesAfter()
    begin
        //-NPR5.48 [334573]
        if "Delete Price Log Entries after" > 0 then
            exit;

        "Delete Price Log Entries after" := (CreateDateTime(Today, 0T) - CreateDateTime(CalcDate('<-90D>', Today), 010000T));
        //+NPR5.48 [334573]
    end;
}

