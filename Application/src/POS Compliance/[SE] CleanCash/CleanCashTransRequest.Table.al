table 6014438 "NPR CleanCash Trans. Request"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = EndUserPseudonymousIdentifiers;
            AutoIncrement = true;
            Description = 'Register receipt serial number, a unique serial number for each receipt registered in a session. If the same serialnumber is sent repeatedly all but the first are ignored. (Max value 4294967295)';
        }

        field(10; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
            Description = 'Link to actual receipt.';
        }

        field(12; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            Description = 'Specifies POS Unit making transaction.';
        }

        field(15; "POS Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            Description = 'POS Receipt No.';
        }

        field(20; "Request Datetime"; DateTime)
        {
            Caption = 'Request Datetime';
            DataClassification = CustomerContent;
            Description = 'Specifies when request was created.';
        }

        field(25; "Request Send Status"; Enum "NPR CleanCash Transaction Status")
        {
            Caption = 'Request Send Status';
            DataClassification = CustomerContent;
            Description = 'Specifies send status of request.';
            InitValue = PENDING;
        }

        field(30; "Request Type"; Enum "NPR CleanCash Request Type")
        {
            Caption = 'Request Type';
            DataClassification = CustomerContent;
            Description = 'The type of request this transaction represents.';

        }

        field(35; "Response Count"; Integer)
        {
            Caption = 'Response Count';
            DataClassification = CustomerContent;
            Description = 'Specifies number of responses.';
        }

        field(100; "Receipt DateTime"; Datetime)
        {
            Caption = 'Receipt Date and Time';
            DataClassification = CustomerContent;
            Description = 'Receipt date in format YYYYMMDDhhmm [Corresponds to Skatteverket’s field “Datum och tid“]';
        }

        field(110; "Receipt Id"; Text[12])
        {
            Caption = 'Receipt Id';
            DataClassification = CustomerContent;
            Description = 'A unique ID for the receipt. (Max 12 digits) [Corresponds to Skatteverket’s field “Löpnummer“]';
        }

        field(120; "Pos Id"; Text[16])
        {
            Caption = 'Pos Id';
            DataClassification = CustomerContent;
            Description = 'String containing the POS terminal‟s ID. (Max 16 character alphanumeric) [Corresponds to Skatteverket’s field “KassaID“]';
        }

        field(130; "Organisation No."; Code[10])
        {
            Caption = 'Organisation No.';
            DataClassification = AccountData;
            Description = 'Organisation number. The Swedish organisation number of the dealer. Format XXXXXXXXXX. [Corresponds to Skatteverket’s field “organisationsnummer“]';
        }

        field(140; "Receipt Total"; Decimal)
        {
            Caption = 'Receipt Total';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
            Description = 'The total net sales amount including VAT.';
        }

        field(150; "Negative Total"; Decimal)
        {
            Caption = 'Negative Total';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
            Description = 'The total amount of negative items on receipt that are included in calculation of Receipt total. (See SKVFS 2009:1, definition of “Returposter”) [Corresponds to Skatteverket’s field ‘Returbelopp’]';
        }

        field(160; "Receipt Type"; Enum "NPR CleanCash Receipt Type")
        {
            Caption = 'Receipt Type';
            DataClassification = CustomerContent;
            Description = 'Receipt type. The type of receipt. Valid values are: - normal (Normal sales receipt) - kopia (Copy of sales receipt) - ovning (Training mode sales receipt) - profo (Pro forma receipt) [Corresponds to Skatteverket’s field ‘Kvittotyp’]';
            InitValue = NO_VALUE;
        }

        field(200; "CleanCash Code"; Text[100])
        {
            Caption = 'CleanCash Code';
            DataClassification = CustomerContent;
            Description = 'A base-32 encoded string to be printed on the printer and stored in the POS terminal‟s journal. The total length of the control code is 59 characters. Note: This is only sent for receipts of type “normal” or “kopia”.';
        }

        field(210; "CleanCash Unit Id"; Text[20])
        {
            Caption = 'CleanCash Unit Id';
            DataClassification = CustomerContent;
            Description = 'The CleanCash manufacturing id code (“Tillverkningsnummer”). Maximum of 17 alphanumeric characters.';
        }

        field(220; "CleanCash Main Status"; Enum "NPR CleanCash Unit Main Status")
        {
            Caption = 'CleanCash Main Status';
            DataClassification = CustomerContent;
            Description = 'CleanCash unit main status.';
            InitValue = NO_VALUE;
        }
        field(230; "CleanCash Storage Status"; Enum "NPR CleanCash Unit Storage Status")
        {
            Caption = 'CleanCash Unit Storage Status';
            DataClassification = CustomerContent;
            Description = 'CleanCash unit storage status.';
            InitValue = NO_VALUE;
        }

    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(PosEntryNo; "POS Entry No.")
        {

        }
    }
}