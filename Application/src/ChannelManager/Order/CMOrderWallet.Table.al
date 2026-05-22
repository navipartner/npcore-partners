table 6059935 "NPR CMOrderWallet"
{
    Access = Internal;
    Caption = 'OTA Channel Manager Order Wallet';
    DataClassification = CustomerContent;

    fields
    {
        field(1; OrderId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Order Id';
            NotBlank = true;
            TableRelation = "NPR CMOrder".OrderId;
        }

        field(2; LineNo; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }

        field(3; SeqNo; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Seq. No.';
        }

        field(10; WalletEntryNo; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Wallet Entry No.';
            TableRelation = "NPR AttractionWallet".EntryNo;
        }

        field(30; ExternalReferenceNumber; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'External Reference Number';
        }

        field(40; WalletName; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Wallet Name';
        }

        field(50; UnitPriceExclVat; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Unit Price Excl. VAT';
            AutoFormatType = 2;
        }

        field(51; UnitPriceInclVat; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Unit Price Incl. VAT';
            AutoFormatType = 2;
        }

        field(52; CurrencyCode; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Currency Code';
            TableRelation = Currency.Code;
        }

        field(60; IssuedAt; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Issued At';
        }

        field(70; ManifestUrl; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Manifest URL';
            ExtendedDatatype = URL;
        }

        field(80; ManifestId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Manifest Id';
        }
    }

    keys
    {
        key(Key1; OrderId, LineNo, SeqNo)
        {
            Clustered = true;
        }

        key(Key2; WalletEntryNo)
        {
            Clustered = false;
        }

        key(Key3; ExternalReferenceNumber)
        {
            Clustered = false;
        }
    }
}
