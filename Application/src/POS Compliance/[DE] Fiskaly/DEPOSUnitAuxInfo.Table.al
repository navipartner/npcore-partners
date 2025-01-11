table 6014532 "NPR DE POS Unit Aux. Info"
{
    Access = Internal;
    Caption = 'DE Fiskaly TSS Client';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(2; "Cash Register Brand"; Text[250])
        {
            Caption = 'Cash Register Brand (Manufacturer)';
            DataClassification = CustomerContent;
        }
        field(3; "Cash Register Model"; Text[250])
        {
            Caption = 'Cash Register Model';
            DataClassification = CustomerContent;
        }
        field(10; "Client ID"; Guid)
        {
            Caption = 'Client ID';
            Editable = false;
            Description = 'Client ID for DE Fiskaly';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Use field SystemId instead';
        }
        field(20; "TSS ID"; Guid)
        {
            Caption = 'TSS ID';
            Editable = false;
            Description = 'TSS ID for DE Fiskaly';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by field "TSS Code" and related table 6014685 "NPR DE TSS"';
        }
        field(21; "TSS Code"; Code[10])
        {
            Caption = 'TSS Code';
            TableRelation = "NPR DE TSS";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "TSS Code" <> xRec."TSS Code" then
                    TestField("Fiskaly Client Created at", 0DT);
            end;
        }
        field(30; "Serial Number"; Text[250])
        {
            Caption = 'Serial Number';
            Description = 'Serial Number for DE Fiskaly';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Serial Number" <> xRec."Serial Number" then
                    TestField("Fiskaly Client Created at", 0DT);
                if "Serial Number" = '' then
                    exit;
                "Serial Number" := DelChr("Serial Number", '=', '/_');
            end;
        }
        field(40; "Cash Register Created"; Boolean)
        {
            Caption = 'Cash Register Created';
            Description = 'Is Cash Register Created for DE Fiskaly DSFINVK';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50; "Fiskaly Client Created at"; DateTime)
        {
            Caption = 'Fiskaly Client Created at';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60; "Fiskaly Client State"; Enum "NPR DE TSS Client State")
        {
            Caption = 'Last Known Fiskaly Client State';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(100; "Additional Data Created"; Boolean)
        {
            Caption = 'Additional Data Created';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(105; "Additional Data Decommissioned"; Boolean)
        {
            Caption = 'Additional Data Decommissioned';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(110; "Acquisition Date"; Date)
        {
            Caption = 'Acquisition Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Acquisition Date" <> xRec."Acquisition Date" then
                    TestField("Additional Data Created", false);
            end;
        }
        field(115; "Commissioning Date"; Date)
        {
            Caption = 'Commissioning Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Commissioning Date" <> xRec."Commissioning Date" then
                    TestField("Additional Data Created", false);
            end;
        }
        field(120; "Decommissioning Date"; Date)
        {
            Caption = 'Decommissioning Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Decommissioning Date" <> xRec."Decommissioning Date" then
                    TestField("Additional Data Decommissioned", false);
            end;
        }
        field(125; "Decommissioning Reason"; Text[1000])
        {
            Caption = 'Decommissioning Reason';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Decommissioning Reason" <> xRec."Decommissioning Reason") and ("Decommissioning Reason" <> '') then
                    TestField("Decommissioning Date");
            end;
        }
        field(130; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code (Establishment)';
            DataClassification = CustomerContent;
            TableRelation = "NPR DE Establishment";

            trigger OnValidate()
            begin
                if "POS Store Code" <> xRec."POS Store Code" then
                    TestField("Additional Data Created", false);
            end;
        }
        field(135; "Establishment Id"; Guid)
        {
            Caption = 'Establishment Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(140; Remarks; Text[1000])
        {
            Caption = 'Remarks';
            DataClassification = CustomerContent;
        }
        field(145; Software; Text[250])
        {
            Caption = 'Software';
            DataClassification = CustomerContent;
        }
        field(150; "Software Version"; Text[250])
        {
            Caption = 'Software Version';
            DataClassification = CustomerContent;
        }
        field(155; "Client Type"; Enum "NPR DE Client Type")
        {
            Caption = 'Client Type';
            DataClassification = CustomerContent;
            InitValue = 1;

            trigger OnValidate()
            begin
                if "Client Type" <> xRec."Client Type" then
                    TestField("Additional Data Created", false);
            end;
        }
    }

    keys
    {
        key(PK; "POS Unit No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        SystemId := CreateGuid();
    end;

    internal procedure GetWithCheck(POSUnitNo: Code[10])
    begin
        Get(POSUnitNo);
        TestField("Additional Data Created");
    end;

    internal procedure CheckIsClientTypePopulated()
    var
        NotPopulatedErr: Label '%1 must be populated for %2 %3.', Comment = '%1 - Client Type field caption, %2 - POS Unit Number field value, %3 - DE POS Unit Aux. Info table caption';
    begin
        if "Client Type" = "Client Type"::" " then
            Error(NotPopulatedErr, FieldCaption("Client Type"), "POS Unit No.", TableCaption());
    end;
}
