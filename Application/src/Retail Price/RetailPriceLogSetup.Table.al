table 6014475 "NPR Retail Price Log Setup"
{
    Access = Internal;
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
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Task Queue module to be removed from NP Retail. We are now using Job Queue instead. There is a new field here, "Job Queue Activated';
            Caption = 'Task Queue Activated';
            DataClassification = CustomerContent;
        }
        field(11; "Job Queue Activated"; Boolean)
        {
            Caption = 'Job Queue Activated';
            DataClassification = CustomerContent;
        }
        field(12; "Job Queue Category Code"; Code[10])
        {
            Caption = 'Job Queue Category Code';
            DataClassification = CustomerContent;
            TableRelation = "Job Queue Category";

            trigger OnValidate()
            var
                RetailPriceLogMgt: Codeunit "NPR Retail Price Log Mgt.";
            begin
                if Rec."Job Queue Category Code" <> xRec."Job Queue Category Code" then begin
                    RetailPriceLogMgt.DeletePriceLogJobQueue(xRec."Job Queue Category Code");
                    if Rec."Job Queue Category Code" <> '' then
                        RetailPriceLogMgt.CreatePriceLogJobQueue(Rec."Job Queue Category Code");
                end;
            end;
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
        InitDeletePriceLogEntriesAfter();
    end;

    local procedure InitDeletePriceLogEntriesAfter()
    begin
        if "Delete Price Log Entries after" > 0 then
            exit;

        "Delete Price Log Entries after" := (CreateDateTime(Today, 0T) - CreateDateTime(CalcDate('<-90D>', Today), 010000T));
    end;
}

