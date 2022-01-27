table 6014509 "NPR Warranty Directory"
{
    Access = Internal;
    Caption = 'Warranty Directory';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used';

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(5; "Link Service to Service Item"; Boolean)
        {
            Caption = 'Link Service to Service Item';
            DataClassification = CustomerContent;
        }
        field(8; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
        }
        field(9; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(10; "Name 2"; Text[50])
        {
            Caption = 'Name 2';
            DataClassification = CustomerContent;
        }
        field(11; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(12; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(13; City; Text[30])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(14; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
        }
        field(15; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
        }
        field(16; "E-Mail"; Text[80])
        {
            Caption = 'E-Mail';
            DataClassification = CustomerContent;
        }
        field(17; "Phone No. 2"; Text[30])
        {
            Caption = 'Phone No. 2';
            DataClassification = CustomerContent;
        }
        field(18; "Fax No."; Text[30])
        {
            Caption = 'Fax No.';
            DataClassification = CustomerContent;
        }
        field(19; "Your Reference"; Text[30])
        {
            Caption = 'Your Reference';
            DataClassification = CustomerContent;
        }
        field(20; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(21; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(34; "Shortcut Dimension 1 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
        }
        field(35; "Shortcut Dimension 2 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
        }
        field(36; "Notify Customer"; Option)
        {
            Caption = 'Notify Customer';
            OptionCaption = 'No,By Phone 1,By Phone 2,By Fax,By E-Mail';
            OptionMembers = No,"By Phone 1","By Phone 2","By Fax","By E-Mail";
            DataClassification = CustomerContent;
        }
        field(39; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
        }
        field(40; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            DataClassification = CustomerContent;
        }
        field(41; "Contact Name"; Text[30])
        {
            Caption = 'Contact Name';
            DataClassification = CustomerContent;
        }
        field(42; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            DataClassification = CustomerContent;
        }
        field(43; "Bill-to Name"; Text[30])
        {
            Caption = 'Bill-to Name';
            DataClassification = CustomerContent;
        }
        field(44; "Bill-to Address"; Text[30])
        {
            Caption = 'Bill-to Address';
            DataClassification = CustomerContent;
        }
        field(45; "Bill-to Address 2"; Text[30])
        {
            Caption = 'Bill-to Address 2';
            DataClassification = CustomerContent;
        }
        field(46; "Bill-to Post Code"; Code[20])
        {
            Caption = 'Bill-to Post Code';
            DataClassification = CustomerContent;
        }
        field(47; "Bill-to City"; Text[30])
        {
            Caption = 'Bill-to City';
            DataClassification = CustomerContent;
        }
        field(48; "Bill-to Contact"; Text[30])
        {
            Caption = 'Bill-to Contact';
            DataClassification = CustomerContent;
        }
        field(49; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            DataClassification = CustomerContent;
        }
        field(50; "Ship-to Name"; Text[30])
        {
            Caption = 'Ship-to Name';
            DataClassification = CustomerContent;
        }
        field(51; "Ship-to Address"; Text[30])
        {
            Caption = 'Ship-to Address';
            DataClassification = CustomerContent;
        }
        field(52; "Ship-to Address 2"; Text[30])
        {
            Caption = 'Ship-to Address 2';
            DataClassification = CustomerContent;
        }
        field(53; "Ship-to Post Code"; Code[20])
        {
            Caption = 'Ship-to Post Code';
            DataClassification = CustomerContent;
        }
        field(54; "Ship-to City"; Text[30])
        {
            Caption = 'Ship-to City';
            DataClassification = CustomerContent;
        }
        field(55; "Ship-to Fax No."; Text[30])
        {
            Caption = 'Ship-to Fax No.';
            DataClassification = CustomerContent;
        }
        field(56; "Ship-to E-Mail"; Text[80])
        {
            Caption = 'Ship-to E-Mail';
            DataClassification = CustomerContent;
        }
        field(57; "Ship-to Contact"; Text[30])
        {
            Caption = 'Ship-to Contact';
            DataClassification = CustomerContent;
        }
        field(58; "Ship-to Phone"; Text[30])
        {
            Caption = 'Ship-to Phone';
            DataClassification = CustomerContent;
        }
        field(59; "Ship-to Phone 2"; Text[30])
        {
            Caption = 'Ship-to Phone 2';
            DataClassification = CustomerContent;
        }
        field(60; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            DataClassification = CustomerContent;
        }
        field(63; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
        }
        field(64; "Job No."; Code[20])
        {
            Caption = 'Job No.';
            DataClassification = CustomerContent;
        }
        field(65; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
        }
        field(66; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
        }
        field(67; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DataClassification = CustomerContent;
        }
        field(69; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            DataClassification = CustomerContent;
        }
        field(70; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
        }
        field(71; "Price Group Code"; Code[10])
        {
            Caption = 'Price Group Code';
            DataClassification = CustomerContent;
        }
        field(72; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
        }
        field(73; "Price Includes VAT"; Boolean)
        {
            Caption = 'Price Includes VAT';
            DataClassification = CustomerContent;
        }
        field(74; "VAT Registration No."; Text[20])
        {
            Caption = 'VAT Registration No.';
            DataClassification = CustomerContent;
        }
        field(76; "VAT Base Discount %"; Decimal)
        {
            Caption = 'VAT Base Discount %';
            DataClassification = CustomerContent;
        }
        field(77; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            DataClassification = CustomerContent;
        }
        field(80; "Cust./Item Disc. Gr."; Code[10])
        {
            Caption = 'Cust./Item Disc. Gr.';
            DataClassification = CustomerContent;
        }
        field(82; Reserve; Option)
        {
            Caption = 'Reserve';
            OptionCaption = 'Never,Optional,Always';
            OptionMembers = Never,Optional,Always;
            DataClassification = CustomerContent;
        }
        field(83; "Bill-to County"; Text[30])
        {
            Caption = 'Bill-to County';
            DataClassification = CustomerContent;
        }
        field(84; County; Text[30])
        {
            Caption = 'County';
            DataClassification = CustomerContent;
        }
        field(85; "Ship-to County"; Text[30])
        {
            Caption = 'Ship-to County';
            DataClassification = CustomerContent;
        }
        field(86; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            DataClassification = CustomerContent;
        }
        field(87; "Bill-to Name 2"; Text[30])
        {
            Caption = 'Bill-to Name 2';
            DataClassification = CustomerContent;
        }
        field(88; "Bill-to Country Code"; Code[10])
        {
            Caption = 'Bill-to Country Code';
            DataClassification = CustomerContent;
        }
        field(89; "Ship-to Name 2"; Text[30])
        {
            Caption = 'Ship-to Name 2';
            DataClassification = CustomerContent;
        }
        field(90; "Ship-to Country Code"; Code[10])
        {
            Caption = 'Ship-to Country Code';
            DataClassification = CustomerContent;
        }
        field(91; Supplier; Code[30])
        {
            Caption = 'Supplier';
            DataClassification = CustomerContent;
        }
        field(100; "Type from Audit Roll"; Option)
        {
            Caption = 'Type from Audit Roll';
            OptionCaption = 'G/L,Item,Payment,Open/Close,Customer,Debit Sale,Interrupted,Comment';
            OptionMembers = "G/L",Item,Payment,"Open/Close",Customer,"Debit Sale",Interrupted,Comment;
            DataClassification = CustomerContent;
        }
        field(101; "No. from Audit Roll"; Code[20])
        {
            Caption = 'No. Type from Audit Roll';
            DataClassification = CustomerContent;
        }
        field(102; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(103; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
        }
        field(104; "Line Discount Amount"; Decimal)
        {
            Caption = 'Line Discount Amount';
            DataClassification = CustomerContent;
        }
        field(105; "Serial No."; Code[20])
        {
            Caption = 'Serial No.';
            DataClassification = CustomerContent;
        }
        field(106; "Serial No. not Created"; Code[30])
        {
            Caption = 'Serial No. not Created';
            DataClassification = CustomerContent;
        }
        field(107; "Rettet den"; Date)
        {
            Caption = 'Edited on';
            DataClassification = CustomerContent;
        }
        field(108; Bonnummer; Code[20])
        {
            Caption = 'Ticket No.';
            DataClassification = CustomerContent;
        }
        field(109; Kassenummer; Code[10])
        {
            Caption = 'Register No.';
            DataClassification = CustomerContent;
        }
        field(111; Debitortype; Option)
        {
            Caption = 'Debit Type';
            OptionCaption = 'Normal,Cash';
            OptionMembers = Alm,Kontant;
            DataClassification = CustomerContent;
        }
        field(112; Ekspart; Integer)
        {
            Caption = 'Ex.part';
            DataClassification = CustomerContent;
        }
        field(113; LinieNo; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(114; "Police 1"; Code[20])
        {
            Caption = 'Police 1';
            DataClassification = CustomerContent;
        }
        field(115; "Police udstedt"; Boolean)
        {
            Caption = 'Police Issued';
            DataClassification = CustomerContent;
        }
        field(116; "Police 2"; Code[20])
        {
            Caption = 'Police 2';
            DataClassification = CustomerContent;
        }
        field(117; "Police 3"; Code[20])
        {
            Caption = 'Police 3';
            DataClassification = CustomerContent;
        }
        field(118; "Premium 1"; Decimal)
        {
            Caption = 'Insurance Amount 1';
            DataClassification = CustomerContent;
        }
        field(119; "Premium 2"; Decimal)
        {
            Caption = 'Insurance Amount 2';
            DataClassification = CustomerContent;
        }
        field(120; "Premium 3"; Decimal)
        {
            Caption = 'Insurance Amount 3';
            DataClassification = CustomerContent;
        }
        field(121; "Locking code"; Code[10])
        {
            Caption = 'Locking code';
            DataClassification = CustomerContent;
        }
        field(122; "Police 2 udstedt"; Boolean)
        {
            Caption = 'Police 2 issued';
            DataClassification = CustomerContent;
        }
        field(123; "Police 3 udstedt"; Boolean)
        {
            Caption = 'Police 3 issued';
            DataClassification = CustomerContent;
        }
        field(124; "Police 1 End Date"; Date)
        {
            Caption = 'Police 1 expiry date';
            DataClassification = CustomerContent;
        }
        field(125; "Police 2 End Date"; Date)
        {
            Caption = 'Police 2 expiry date';
            DataClassification = CustomerContent;
        }
        field(126; "Police 3 End Date"; Date)
        {
            Caption = 'Police 3 expiry date';
            DataClassification = CustomerContent;
        }
        field(127; "Insurance sold"; Boolean)
        {
            Caption = 'Insurance sold';
            DataClassification = CustomerContent;
        }
        field(128; GuidName; Guid)
        {
            Caption = 'GUID Name';
            DataClassification = CustomerContent;
        }
        field(129; "Insurance Sent"; Date)
        {
            Caption = 'Insurance send';
            DataClassification = CustomerContent;
        }
        field(200; "Delivery Date"; Date)
        {
            Caption = 'Delivery Date';
            DataClassification = CustomerContent;
        }
        field(6014501; "1. Service Incoming"; Date)
        {
            Caption = '1. Service Incoming';
            DataClassification = CustomerContent;
        }
        field(6014502; "1. Service Done"; Date)
        {
            Caption = '1. Service Done';
            DataClassification = CustomerContent;
        }
        field(6014503; "2. Service Incoming"; Date)
        {
            Caption = '2. Service Incoming';
            DataClassification = CustomerContent;
        }
        field(6014504; "2. Service Done"; Date)
        {
            Caption = '2. Service Done';
            DataClassification = CustomerContent;
        }
        field(6014505; "3. Service Incoming"; Date)
        {
            Caption = '3. Service Incoming';
            DataClassification = CustomerContent;
        }
        field(6014506; "3. Service Done"; Date)
        {
            Caption = '3. Service Done';
            DataClassification = CustomerContent;
        }
        field(6014507; "4. Service Incoming"; Date)
        {
            Caption = '4. Service Incoming';
            DataClassification = CustomerContent;
        }
        field(6014508; "4. Service Done"; Date)
        {
            Caption = '4. Service Done';
            DataClassification = CustomerContent;
        }
        field(6014509; "5. Service Incoming"; Date)
        {
            Caption = '5. Service Incoming';
            DataClassification = CustomerContent;
        }
        field(6014510; "5. Service Done"; Date)
        {
            Caption = '5. Service Done';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    fieldgroups
    {
    }
}

