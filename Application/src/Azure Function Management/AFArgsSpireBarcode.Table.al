table 6151572 "NPR AF Args: Spire Barcode"
{
    // NPR5.36/CLVA/20170710 CASE 269792 AF Argument Table - Spire

    Caption = 'AF Arguments - Spire';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Guid)
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; Value; Text[250])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
        }
        field(11; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Codabar,Code11,Code25,Interleaved25,Code39,Code39Extended,Code93Extended,Code128,EAN8,EAN13,EAN128,EAN14,SCC14,SSCC18,ITF14,ITF6,UPCA,UPCE,PostNet,Planet,MSI,DataMatrix,QRCode,Pdf417,Pdf417Macro,RSS14,RSS14Truncated,RSSLimited,RSSExpanded,USPS,SwissPostParcel,PZN,OPC,DeutschePostIdentcode,DeutschePostLeitcode,RoyalMail4State,SingaporePost4State,Aztec';
            OptionMembers = Codabar,Code11,Code25,Interleaved25,Code39,Code39Extended,Code93Extended,Code128,EAN8,EAN13,EAN128,EAN14,SCC14,SSCC18,ITF14,ITF6,UPCA,UPCE,PostNet,Planet,MSI,DataMatrix,QRCode,Pdf417,Pdf417Macro,RSS14,RSS14Truncated,RSSLimited,RSSExpanded,USPS,SwissPostParcel,PZN,OPC,DeutschePostIdentcode,DeutschePostLeitcode,RoyalMail4State,SingaporePost4State,Aztec;
        }
        field(12; "Show Checksum"; Boolean)
        {
            Caption = 'Show Checksum';
            DataClassification = CustomerContent;
            InitValue = false;
        }
        field(13; "Barcode Height"; Integer)
        {
            Caption = 'Barcode Height';
            DataClassification = CustomerContent;
            InitValue = 15;
        }
        field(14; "Include Text"; Boolean)
        {
            Caption = 'Include Text';
            DataClassification = CustomerContent;
            InitValue = false;
        }
        field(15; Border; Boolean)
        {
            Caption = 'Border';
            DataClassification = CustomerContent;
            InitValue = false;
        }
        field(16; "Reverse Colors"; Boolean)
        {
            Caption = 'Reverse Colors';
            DataClassification = CustomerContent;
            InitValue = false;
        }
        field(17; "Image Type"; Option)
        {
            Caption = 'Image Type';
            DataClassification = CustomerContent;
            InitValue = Png;
            OptionCaption = 'Png,Gif,Jpg';
            OptionMembers = Png,Gif,Jpg;
        }
        field(18; Image; BLOB)
        {
            Caption = 'Image';
            DataClassification = CustomerContent;
            SubType = Bitmap;
        }
        field(19; Picture; Media)
        {
            Caption = 'Image';
            DataClassification = CustomerContent;
        }
        field(21; "Barcode Size"; Integer)
        {
            Caption = 'Barcode Size';
            DataClassification = CustomerContent;
            InitValue = 1;
        }
        field(100; "API Key"; Text[100])
        {
            Caption = 'API Key';
            DataClassification = CustomerContent;
        }
        field(101; "Base Url"; Text[100])
        {
            Caption = 'Base Url';
            DataClassification = CustomerContent;
        }
        field(102; "API Routing"; Text[100])
        {
            Caption = 'API Routing';
            DataClassification = CustomerContent;
        }
        field(103; "Request OK"; Boolean)
        {
            Caption = 'Request OK';
            DataClassification = CustomerContent;
        }
        field(104; Result; Text[250])
        {
            Caption = 'Result';
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
}

