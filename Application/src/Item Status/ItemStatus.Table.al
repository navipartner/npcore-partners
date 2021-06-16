table 6060054 "NPR Item Status"
{
    // NPR5.25\BR  \20160720  CASE 246088 Object Created

    Caption = 'Item Status';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Item Status";
    LookupPageID = "NPR Item Status";

    fields
    {
        field(10; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(50; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(200; Initial; Boolean)
        {
            Caption = 'Initial';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ItemStatus: Record "NPR Item Status";
                TextOnlyOne: Label 'Only one Status is allowed with field %1 active.';
            begin
                if Initial then begin
                    ItemStatus.SetFilter(Code, '<>%1', Code);
                    ItemStatus.SetRange(Initial, true);
                    if not ItemStatus.IsEmpty then
                        Error(TextOnlyOne, FieldCaption(Initial));
                end;
            end;
        }
        field(210; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
            InitValue = false;
        }
        field(230; "Delete Allowed"; Boolean)
        {
            Caption = 'Delete Allowed';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(240; "Rename Allowed"; Boolean)
        {
            Caption = 'Rename Allowed';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(300; "Purchase Insert"; Boolean)
        {
            Caption = 'Purchase Insert';
            DataClassification = CustomerContent;
            InitValue = true;

            trigger OnValidate()
            begin
                CheckOtherStatusExists(FieldNo("Purchase Insert"), "Purchase Insert");
            end;
        }
        field(310; "Purchase Release"; Boolean)
        {
            Caption = 'Purchase Release';
            DataClassification = CustomerContent;
            InitValue = true;

            trigger OnValidate()
            begin
                CheckOtherStatusExists(FieldNo("Purchase Release"), "Purchase Release");
            end;
        }
        field(320; "Purchase Post"; Boolean)
        {
            Caption = 'Purchase Post';
            DataClassification = CustomerContent;
            InitValue = true;

            trigger OnValidate()
            begin
                CheckOtherStatusExists(FieldNo("Purchase Post"), "Purchase Post");
            end;
        }
        field(400; "Sales Insert"; Boolean)
        {
            Caption = 'Sales Insert';
            DataClassification = CustomerContent;
            InitValue = true;

            trigger OnValidate()
            begin
                CheckOtherStatusExists(FieldNo("Sales Insert"), "Sales Insert");
            end;
        }
        field(410; "Sales Release"; Boolean)
        {
            Caption = 'Sales Release';
            DataClassification = CustomerContent;
            InitValue = true;

            trigger OnValidate()
            begin
                CheckOtherStatusExists(FieldNo("Sales Release"), "Sales Release");
            end;
        }
        field(420; "Sales Post"; Boolean)
        {
            Caption = 'Sales Post';
            DataClassification = CustomerContent;
            InitValue = true;

            trigger OnValidate()
            begin
                CheckOtherStatusExists(FieldNo("Sales Post"), "Sales Post");
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    local procedure CheckOtherStatusExists(ParFieldNo: Integer; ParFieldValue: Boolean)
    var
        RecRef: RecordRef;
        FldRefBoolean: FieldRef;
        FldRefCode: FieldRef;
        TextStatusDoesNotExist: Label 'You cannot switch off this option because no other status exists with option %1 activated.';
    begin
        if ParFieldValue then
            exit;
        RecRef.Open(DATABASE::"NPR Item Status");
        FldRefBoolean := RecRef.Field(ParFieldNo);
        FldRefBoolean.SetRange(true);
        FldRefCode := RecRef.Field(10);
        FldRefCode.SetFilter('<>%1', Code);
        if not RecRef.FindFirst() then
            Error(TextStatusDoesNotExist, FldRefBoolean.Caption);
    end;
}

