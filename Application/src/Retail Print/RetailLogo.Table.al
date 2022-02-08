table 6014478 "NPR Retail Logo"
{
    Access = Internal;
    Caption = 'Retail Logo';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Sequence; Integer)
        {
            Caption = 'Sequence';
            DataClassification = CustomerContent;
        }
        field(2; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            TableRelation = "NPR POS Unit"."No.";

            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(3; Keyword; Code[20])
        {
            Caption = 'Keyword';
            DataClassification = CustomerContent;
        }
        field(4; "Start Date"; Date)
        {
            Caption = 'Start Date';
            DataClassification = CustomerContent;
        }
        field(5; "End Date"; Date)
        {
            Caption = 'End Date';
            DataClassification = CustomerContent;
        }
        field(6; Logo; BLOB)
        {
            Caption = 'Logo';
            SubType = Bitmap;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Use Media instead of Blob type.';
        }
        field(7; ESCPOSLogo; BLOB)
        {
            Caption = 'ESCPOS Logo';
            DataClassification = CustomerContent;
        }
        field(8; Height; Integer)
        {
            Caption = 'Height';
            DataClassification = CustomerContent;
        }
        field(9; Width; Integer)
        {
            Caption = 'Width';
            DataClassification = CustomerContent;
        }
        field(10; "POS Logo"; Media)
        {
            Caption = 'Logo';
            DataClassification = CustomerContent;
        }
        field(100; "ESCPOS Height Low Byte"; Integer)
        {
            Caption = 'ESCPOS Height Low Byte';
            DataClassification = CustomerContent;
        }
        field(101; "ESCPOS Height High Byte"; Integer)
        {
            Caption = 'ESCPOS Height High Byte';
            DataClassification = CustomerContent;
        }
        field(102; "ESCPOS Cmd Low Byte"; Integer)
        {
            Caption = 'ESCPOS Cmd Low Byte';
            DataClassification = CustomerContent;
        }
        field(103; "ESCPOS Cmd High Byte"; Integer)
        {
            Caption = 'ESCPOS Cmd High Byte';
            DataClassification = CustomerContent;
        }
        field(120; OneBitLogo; BLOB)
        {
            Caption = '1-bit Logo';
            DataClassification = CustomerContent;
        }
        field(121; OneBitLogoByteSize; Integer)
        {
            Caption = '1-bit Logo Size in Bytes';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Sequence)
        {
        }
    }

    fieldgroups
    {
    }

    procedure NewRecord()
    var
        RetailLogo2: Record "NPR Retail Logo";
    begin
        if RetailLogo2.FindLast() then;
        Sequence := RetailLogo2.Sequence + 1;
    end;

    procedure GetImageContent(var TenantMedia: Record "Tenant Media")
    begin
        TenantMedia.Init();
        if not Rec."POS Logo".HasValue() then
            exit;
        if TenantMedia.Get(Rec."POS Logo".MediaId()) then
            TenantMedia.CalcFields(Content);
    end;
}

