table 6151374 "NPR CS UI Line"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018
    // NPR5.47/CLVA/20181012 CASE 318296 Changed option string "First Responder"
    // NPR5.48/CLVA/20181207 CASE 336403 Added field "Format Value"

    Caption = 'CS UI Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "UI Code"; Code[20])
        {
            Caption = 'Miniform Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR CS UI Header".Code;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(11; "Area"; Option)
        {
            Caption = 'Area';
            DataClassification = CustomerContent;
            OptionCaption = 'Header,Body,Footer', Locked = true;
            OptionMembers = Header,Body,Footer;
        }
        field(12; "Field Type"; Option)
        {
            Caption = 'Field Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Text,Input,Output,Asterisk,Default', Locked = true;
            OptionMembers = Text,Input,Output,Asterisk,Default;

            trigger OnValidate()
            begin
                if "Field Type" = "Field Type"::Input then begin
                    GetMiniFormHeader;
                    if ((MiniFormHeader."Form Type" = MiniFormHeader."Form Type"::"Selection List") or
                        (MiniFormHeader."Form Type" = MiniFormHeader."Form Type"::"Data List"))
                    then
                        Error(
                          StrSubstNo(Text000,
                            "Field Type", MiniFormHeader.FieldCaption("Form Type"), MiniFormHeader."Form Type"));
                end;
            end;
        }
        field(13; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                if "Field Type" in ["Field Type"::Input, "Field Type"::Output] then begin
                    Field.Reset;
                    if PAGE.RunModal(PAGE::"NPR CS Fields", Field) = ACTION::LookupOK then begin
                        "Table No." := Field.TableNo;
                        Validate("Field No.", Field."No.");
                    end;
                end;
            end;

            trigger OnValidate()
            begin
                if "Table No." <> 0 then begin
                    Field.Reset;
                    Field.SetRange(TableNo, "Table No.");
                    Field.FindFirst;
                end else
                    Validate("Field No.", 0);
            end;
        }
        field(14; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                Field.Reset;
                Field.SetRange(TableNo, "Table No.");
                Field.TableNo := "Table No.";
                Field."No." := "Field No.";
                if PAGE.RunModal(PAGE::"NPR CS Fields", Field) = ACTION::LookupOK then
                    Validate("Field No.", Field."No.");
            end;

            trigger OnValidate()
            begin
                if "Field No." <> 0 then begin
                    Field.Get("Table No.", "Field No.");
                    Validate(Text, Field."Field Caption");
                    Validate("Field Length", Field.Len);
                    "Field Data Type" := Field."Type Name";
                end else begin
                    Validate(Text, '');
                    Validate("Field Length", 0);
                    "Field Data Type" := '';
                end;
            end;
        }
        field(15; "Text"; Text[30])
        {
            Caption = 'Text';
            DataClassification = CustomerContent;
        }
        field(16; "Field Length"; Integer)
        {
            Caption = 'Field Length';
            DataClassification = CustomerContent;
        }
        field(21; "Call UI"; Code[20])
        {
            Caption = 'Call UI';
            DataClassification = CustomerContent;
            TableRelation = "NPR CS UI Header";

            trigger OnValidate()
            begin
                GetMiniFormHeader;
            end;
        }
        field(22; "Field Data Type"; Text[30])
        {
            Caption = 'Field Data Type';
            DataClassification = CustomerContent;
        }
        field(23; "First Responder"; Option)
        {
            Caption = 'First Responder';
            DataClassification = CustomerContent;
            OptionCaption = 'Keyboard,Keyboard(Active),Barcode Reader,Rfid Reader';
            OptionMembers = Keyboard,"Keyboard(Active)","Barcode Reader","Rfid Reader";
        }
        field(24; Placeholder; Text[30])
        {
            Caption = 'Placeholder';
            DataClassification = CustomerContent;
        }
        field(25; "Default Value"; Text[30])
        {
            Caption = 'Default Value';
            DataClassification = CustomerContent;
        }
        field(26; "Format Value"; Boolean)
        {
            Caption = 'Format Value';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "UI Code", "Line No.")
        {
        }
        key(Key2; "Area")
        {
        }
    }

    fieldgroups
    {
    }

    var
        MiniFormHeader: Record "NPR CS UI Header";
        "Field": Record "Field";
        Text000: Label '%1 not allowed for %2 %3 ';

    local procedure GetMiniFormHeader()
    begin
        if MiniFormHeader.Code <> "UI Code" then
            MiniFormHeader.Get("UI Code");
    end;
}

