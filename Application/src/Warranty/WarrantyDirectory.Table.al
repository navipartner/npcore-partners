table 6014509 "NPR Warranty Directory"
{
    // //-NPR3.0h
    //   hvis forsikring er sendt med mail kan der ikke ændres mere. onModify;
    // NPR5.29/MHA /20161212  CASE 256690 Customer Fields extended to match standard
    // NPR5.29/MMV /20170110  CASE 260033 Added report interface support for better webclient printing.
    // NPR5.35/TJ  /20170816  CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                    Removed unused variables
    // NPR5.38/MHA /20180104  CASE 301054 Removed TableRetail to Table0 on field 46,53,63,65,69,72,77,80
    // NPR5.39/TJ  /20180206  CASE 302634 Changed OptionString property of the field 100 "Type from Audit Roll" to english version
    // NPR5.46/JAVA/20180918  CASE 328652 Fix 'DataLength' property of the field 63 "No. Series" (20 => 10).
    //                                    Added 'TableRelation' property of the field 63.

    Caption = 'Warranty Directory';
    LookupPageID = "NPR Warranty Catalog List";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
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
            TableRelation = IF (Debitortype = CONST(Kontant)) Contact
            ELSE
            IF (Debitortype = CONST(Alm)) Customer;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Customer: Record Customer;
                Contact: Record Contact;
            begin
                if (Debitortype = Debitortype::Alm) and ("Customer No." <> '') then begin
                    Customer.Get("Customer No.");
                    Name := Customer.Name;
                    "Name 2" := Customer."Name 2";
                    Address := Customer.Address;
                    "Address 2" := Customer."Address 2";
                    City := Customer.City;
                    "Post Code" := Customer."Post Code";
                    "Phone No." := Customer."Phone No.";
                    "E-Mail" := Customer."E-Mail";
                end;

                if (Debitortype = Debitortype::Kontant) and ("Customer No." <> '') then begin
                    Contact.Get("Customer No.");
                    Name := Contact.Name;
                    "Name 2" := Contact."Name 2";
                    Address := Contact.Address;
                    "Address 2" := Contact."Address 2";
                    City := Contact.City;
                    "Post Code" := Contact."Post Code";
                    "Phone No." := Contact."Phone No.";
                    "E-Mail" := Contact."E-Mail";
                end;
            end;
        }
        field(9; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(10; "Name 2"; Text[50])
        {
            Caption = 'Name 2';
            DataClassification = CustomerContent;
        }
        field(11; Address; Text[50])
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
            TableRelation = "Post Code";
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
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
        }
        field(35; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
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
        field(39; "Salesperson Code"; Code[10])
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
            Description = 'NPR5.38';
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
            Description = 'NPR5.38';
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
        field(63; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            Description = 'NPR5.38,NPR5.46';
            Editable = false;
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(64; "Job No."; Code[20])
        {
            Caption = 'Job No.';
            DataClassification = CustomerContent;
        }
        field(65; "Gen. Bus. Posting Group"; Code[10])
        {
            Caption = 'Gen. Bus. Posting Group';
            Description = 'NPR5.38';
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
            DecimalPlaces = 0 : 15;
            Editable = false;
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(69; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            Description = 'NPR5.38';
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
            Description = 'NPR5.38';
            DataClassification = CustomerContent;
        }
        field(72; "VAT Bus. Posting Group"; Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            Description = 'NPR5.38';
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
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(77; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            Description = 'NPR5.38';
            DataClassification = CustomerContent;
        }
        field(80; "Cust./Item Disc. Gr."; Code[10])
        {
            Caption = 'Cust./Item Disc. Gr.';
            Description = 'NPR5.38';
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
            InitValue = Item;
            OptionCaption = 'G/L,Item,Payment,Open/Close,Customer,Debit Sale,Interrupted,Comment';
            OptionMembers = "G/L",Item,Payment,"Open/Close",Customer,"Debit Sale",Interrupted,Comment;
            DataClassification = CustomerContent;
        }
        field(101; "No. from Audit Roll"; Code[20])
        {
            Caption = 'No. Type from Audit Roll';
            TableRelation = IF ("Type from Audit Roll" = CONST("G/L")) "G/L Account"."No."
            ELSE
            IF ("Type from Audit Roll" = CONST(Payment)) "NPR Payment Type POS"."No."
            ELSE
            IF ("Type from Audit Roll" = CONST(Customer)) Customer."No."
            ELSE
            IF ("Type from Audit Roll" = CONST(Item)) Item."No." WHERE(Blocked = CONST(false));
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(102; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(103; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
        }
        field(104; "Line Discount Amount"; Decimal)
        {
            BlankZero = true;
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
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(109; Kassenummer; Code[10])
        {
            Caption = 'Register No.';
            Editable = false;
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
        field(6014500; Comment; Boolean)
        {
            CalcFormula = Exist ("NPR Retail Comment" WHERE("Table ID" = CONST(6014514),
                                                        "No." = FIELD("No.")));
            Caption = 'Comment';
            FieldClass = FlowField;
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

    trigger OnDelete()
    var
        WarrantyLine: Record "NPR Warranty Line";
    begin
        WarrantyLine.SetRange("Warranty No.", "No.");
        WarrantyLine.DeleteAll;
    end;

    trigger OnInsert()
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if "No." = '' then begin
            RetailContractSetup.Get;
            RetailContractSetup.TestField(RetailContractSetup."Warranty No. Series");
            NoSeriesMgt.InitSeries(RetailContractSetup."Warranty No. Series", '', Today, "No.", RetailContractSetup."Warranty No. Series");
            "No. Series" := RetailContractSetup."Warranty No. Series";
        end;
    end;

    trigger OnModify()
    begin
        "Rettet den" := Today;
    end;

    var
        RetailContractSetup: Record "NPR Retail Contr. Setup";

    procedure Navigate()
    var
        NavigatePage: Page Navigate;
        AuditRoll: Record "NPR Audit Roll";
    begin
        //Navigate
        AuditRoll.SetRange("Register No.", Kassenummer);
        AuditRoll.SetRange("Sales Ticket No.", Bonnummer);

        //RevRulle.SETRANGE( Ekspeditionsart, Ekspart );
        //RevRulle.SETRANGE( RevRulle."Linienr.", LinieNo );
        AuditRoll.Find('-');

        NavigatePage.SetDoc(AuditRoll."Sale Date", AuditRoll."Posted Doc. No.");
        NavigatePage.Run;
    end;

    procedure PrintRec(ShowRequestWindow: Boolean)
    var
        WarrantyDirectory: Record "NPR Warranty Directory";
        ReportSelectionContract: Record "NPR Report Selection: Contract";
        ReportPrinterInterface: Codeunit "NPR Report Printer Interface";
    begin
        //PrintRec
        with WarrantyDirectory do begin
            Copy(Rec);
            ReportSelectionContract.SetRange("Report Type", ReportSelectionContract."Report Type"::"Guarantee Certificate");
            ReportSelectionContract.SetFilter("Report ID", '<>0');
            ReportSelectionContract.Find('-');
            repeat
                //-NPR5.29 [260033]
                ReportPrinterInterface.RunReport(ReportSelectionContract."Report ID", ShowRequestWindow, false, WarrantyDirectory);
            //REPORT.RUNMODAL(RapportValg."Report ID",VisAnfordring,FALSE,GarantiHoved);
            //+NPR5.29 [260033]
            until ReportSelectionContract.Next = 0;
        end;
    end;

    procedure TransferFromAuditRoll(var AuditRoll: Record "NPR Audit Roll"): Boolean
    var
        AuditRoll2: Record "NPR Audit Roll";
        WarrantyDirectory: Record "NPR Warranty Directory";
        WarrantyLine: Record "NPR Warranty Line";
        TxtAuditRoll: Label 'Inserted from the audit roll';
        LineNo: Integer;
        ErrCount: Label 'There are no lines within the filter!';
        MsgInsert: Label '%2 lines are inserted in warranty archive %1';
    begin
        //TransferFromAuditRoll()
        AuditRoll2.Copy(AuditRoll);

        if AuditRoll2.GetFilter("Register No.") = '' then
            AuditRoll2.SetRange("Register No.", AuditRoll."Register No.");
        if AuditRoll2.GetFilter("Sales Ticket No.") = '' then
            AuditRoll2.SetRange("Sales Ticket No.", AuditRoll."Sales Ticket No.");

        AuditRoll2.SetRange("Sale Type", AuditRoll2."Sale Type"::Sale);
        AuditRoll2.SetRange(Type, AuditRoll2.Type::Item);

        if AuditRoll2.Count = 0 then
            Error(ErrCount);

        if AuditRoll2.Find('-') then
            repeat
                LineNo += 10000;
                if WarrantyDirectory."No." = '' then begin
                    WarrantyDirectory.Description := TxtAuditRoll;
                    WarrantyDirectory.Insert(true);
                    WarrantyDirectory.Bonnummer := AuditRoll2."Sales Ticket No.";
                    WarrantyDirectory.Kassenummer := AuditRoll2."Register No.";
                    WarrantyDirectory."Rettet den" := Today;
                    WarrantyDirectory.Modify;
                end;
                if AuditRoll2."Customer No." <> '' then begin
                    WarrantyDirectory.Debitortype := AuditRoll2."Customer Type";
                    WarrantyDirectory.Validate("Customer No.", AuditRoll2."Customer No.");
                    WarrantyDirectory.Modify;
                end;
                WarrantyLine.Init;
                WarrantyLine."Warranty No." := WarrantyDirectory."No.";
                WarrantyLine."Line No." := LineNo;
                WarrantyLine.Validate("Item No.", AuditRoll2."No.");
                WarrantyLine.Validate(Quantity, AuditRoll2.Quantity);
                WarrantyLine."Unit Price" := AuditRoll2."Unit Price";
                WarrantyLine.Amount := AuditRoll2.Amount;
                WarrantyLine."Amount incl. VAT" := AuditRoll2."Amount Including VAT";
                WarrantyLine."Discount %" := AuditRoll2."Line Discount %";
                WarrantyLine.Description := AuditRoll2.Description;
                WarrantyLine.Insert;
            until AuditRoll2.Next = 0;

        Message(MsgInsert, WarrantyDirectory."No.", AuditRoll2.Count);
    end;

    procedure PrintPolicy()
    var
        ReportSelectionContract: Record "NPR Report Selection: Contract";
        ReportPrinterInterface: Codeunit "NPR Report Printer Interface";
    begin
        //PrintPolicy()
        ReportSelectionContract.SetRange("Report Type", ReportSelectionContract."Report Type"::Police);
        if ReportSelectionContract.Find('-') then
            repeat
                if ReportSelectionContract."Report ID" <> 0 then
                    //-NPR5.29 [260033]
                    ReportPrinterInterface.RunReport(ReportSelectionContract."Report ID", true, true, Rec);
                //REPORT.RUN( FotoRapport."Report ID", TRUE, TRUE, Rec );
                //+NPR5.29 [260033]

                if ReportSelectionContract."XML Port ID" <> 0 then
                    XMLPORT.Run(ReportSelectionContract."XML Port ID", false, false, Rec);

            until ReportSelectionContract.Next = 0;
    end;

    procedure UpdatePremium()
    var
        InsuranceCombination: Record "NPR Insurance Combination";
        RetailContractSetup2: Record "NPR Retail Contr. Setup";
        WarrantyLine: Record "NPR Warranty Line";
        InsuranceCategory: Record "NPR Insurance Category";
        Total: Decimal;
        PolicyNo: Integer;
    begin
        //UpdatePremium()
        if RetailContractSetup2.Get() then;
        WarrantyLine.SetRange("Warranty No.", "No.");

        for PolicyNo := 1 to 3 do begin
            Total := 0;
            WarrantyLine.SetCurrentKey("Warranty No.", "Policy 1", "Policy 2", "Policy 3", InsuranceType);
            case PolicyNo of
                1:
                    begin
                        WarrantyLine.SetRange("Policy 1", true);
                        WarrantyLine.SetRange("Policy 2", false);
                        WarrantyLine.SetRange("Policy 3", false);
                    end;
                2:
                    begin
                        WarrantyLine.SetRange("Policy 1", false);
                        WarrantyLine.SetRange("Policy 2", true);
                        WarrantyLine.SetRange("Policy 3", false);
                    end;
                3:
                    begin
                        WarrantyLine.SetRange("Policy 1", false);
                        WarrantyLine.SetRange("Policy 2", false);
                        WarrantyLine.SetRange("Policy 3", true);
                    end;
            end;
            if InsuranceCategory.Find('-') then
                repeat
                    WarrantyLine.SetRange(InsuranceType, InsuranceCategory.Kategori);
                    WarrantyLine.CalcSums("Amount incl. VAT");
                    WarrantyLine."Amount incl. VAT" := Round(WarrantyLine."Amount incl. VAT", 1, '<');
                    InsuranceCombination.SetRange(Company, RetailContractSetup2."Default Insurance Company");
                    InsuranceCombination.SetRange(Type, InsuranceCategory.Kategori);
                    InsuranceCombination.SetFilter("Amount From", '<=%1', WarrantyLine."Amount incl. VAT");
                    InsuranceCombination.SetFilter("To Amount", '>=%1', WarrantyLine."Amount incl. VAT");
                    if InsuranceCombination.Find('-') then begin
                        Total += InsuranceCombination."Insurance Amount";
                    end;
                until InsuranceCategory.Next = 0;

            case PolicyNo of
                1:
                    begin
                        Validate("Premium 1", Total);
                    end;
                2:
                    begin
                        Validate("Premium 2", Total);
                    end;
                3:
                    begin
                        Validate("Premium 3", Total);
                    end;
            end;
        end;
        //Rec.MODIFY();
    end;
}

