table 6150631 "NPR POS Unit Event"
{
    DataClassification = CustomerContent;
    Caption = 'POS Unit Event';
    LookupPageId = "NPR POS Unit Event List";

    fields
    {
        field(1; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR POS Unit"."No.";
        }
        field(2; "Active Event No."; Code[20])
        {
            Caption = 'Active Event No.';
            DataClassification = CustomerContent;
            TableRelation = Job WHERE("NPR Event" = CONST(true));
        }
    }

    keys
    {
        key(PK; "POS Unit No.")
        {
            Clustered = true;
        }
    }

    procedure FindActiveEvent(POSUnitNo: Code[10]): Code[20]
    begin
        "POS Unit No." := POSUnitNo;
        if not Find() then
            exit;
        exit("Active Event No.");
    end;

    procedure SetActiveEvent(POSUnitNo: Code[10]; EventNo: Code[20])
    begin
        "POS Unit No." := POSUnitNo;
        if not Find() then begin
            Init();
            Insert();
        end;
        "Active Event No." := EventNo;
        Modify();
    end;

    procedure DeleteActiveEvent(POSUnitNo: Code[10])
    begin
        "POS Unit No." := POSUnitNo;
        if not Find() then
            exit;
        Delete();
    end;
}