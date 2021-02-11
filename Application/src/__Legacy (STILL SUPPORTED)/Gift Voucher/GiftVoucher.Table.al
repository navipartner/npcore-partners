table 6014409 "NPR Gift Voucher"
{
    // //NPR2.2r - Ohm - "Indl¢st den" som n¢gle
    // //
    // //001,002,003 - Ohm - 210704
    //   MySQL clearing integration - set status of gift voucher
    //   Insert, modify, delete
    //   - hvis denne kode ikke skal bruges så fjern KUN i modtagers objekt.
    // 
    // //NPR3.01j - NE - tilf¢jet det boolske flowfield comment
    // 
    // //NPK1.0 , 13-03-12, job 118881, JS - Modified the print function, so i only prints for a specific register.
    // NPR70.00.01.01/MH/20150113  CASE 199932 Removed Web references (WEB1.00).
    // NPR70.00.01.02/MH/20150205  CASE 199932 Original No. from No. Series is transfered to "Voucher No." OnInsert.
    // MAG1.03/MH/20150205  CASE 199932 Added field 6059860 Gift Voucher Message.
    // MAG1.04/TS/20150206  CASE 201682 Adding Magento Hooks - Changed field Status Caption
    // MAG1.06/TS/20150223  CASE 201682 Added Initial Amount = Amount
    // NPR4.15/MMV/20151007 CASE 223991 Added handling of printing gift vouchers with label module.
    //                                  Fixed no filter attempt on register no. when printing through codeunit.
    // NPR5.22/MMV/20160421 CASE 237314 Added support for retail report selection mgt.
    // MAG1.22/MHA/20160427 CASE 240257 MagentoHooks removed and converted to EventSubscriber: OnInsert() and OnModify()
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // NPR5.29/MMV /20161216 CASE 241549 Removed deprecated print/report code.
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.35/TJ  /20170809 CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                   Removed unused variables
    // NPR5.38/MHA /20180104  CASE 301054 Removed Property, Title, from field 10 Name, 11 Address, 13 City
    // NPR5.38/BR  /20180119  CASE 302766 Added POS Entry links
    // NPR5.39/JDH /20180220 CASE 305746 Name Extended to 50

    Caption = 'Gift Voucher';
    DataClassification = CustomerContent;
    LookupPageID = "NPR Gift Voucher List";
    Permissions = TableData "NPR I-Comm" = rimd;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                RetailSetup.Get();
                if "No." <> xRec."No." then begin
                    if "External Gift Voucher" then
                        NoSeriesMgt.TestManual(RetailSetup."Foreign Gift Voucher no.Series")
                    else
                        NoSeriesMgt.TestManual(RetailSetup."Gift Voucher No. Management");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
        }
        field(3; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(4; "Issue Date"; Date)
        {
            Caption = 'Issue Date';
            DataClassification = CustomerContent;
        }
        field(5; "Salesperson Code"; Code[10])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(6; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(7; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(8; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Open,Cashed,Cancelled';
            OptionMembers = Open,Cashed,Cancelled;

            trigger OnValidate()
            var
                TestAmount: Decimal;
            begin
                RetailSetup.Get;

                if (xRec.Status = Status::Cashed) and (Status = Status::Open) then begin
                    "Cashed on Register No." := '';
                    "Cashed on Sales Ticket No." := '';
                    "Cashed Date" := 0D;
                    "Cashed Salesperson" := '';
                    "Cashed in Global Dim 1 Code" := '';
                    "Cashed in Location Code" := '';
                    "Cashed External" := false;
                end;

                if RetailSetup."Use I-Comm" then begin
                    RecIComm.Get;
                    if RecIComm."Company - Clearing" <> '' then
                        if xRec.Status <> Status then
                            IComm.DBGiftVoucher(Rec, false, true, true, TestAmount);
                end;
            end;
        }
        field(9; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            FieldClass = Normal;
            MaxValue = 9999999;
        }
        field(10; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
        }
        field(11; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
        }
        field(12; "ZIP Code"; Code[20])
        {
            Caption = 'ZIP Code';
            DataClassification = CustomerContent;
            TableRelation = "Post Code";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin

                PostCode.Reset;
                PostCode.SetRange(Code, "ZIP Code");
                if PostCode.Find('-') then
                    City := PostCode.City;
            end;
        }
        field(13; City; Text[50])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
        }
        field(22; "Cashed on Register No."; Code[10])
        {
            Caption = 'Cashed on Cash Register No.';
            DataClassification = CustomerContent;
        }
        field(23; "Cashed on Sales Ticket No."; Code[20])
        {
            Caption = 'Cashed on Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(24; "Cashed Date"; Date)
        {
            Caption = 'Cashed Date';
            DataClassification = CustomerContent;
        }
        field(25; "Cashed Salesperson"; Code[10])
        {
            Caption = 'Cashed Salesperson';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser";
        }
        field(26; "Cashed in Global Dim 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Cashed in Department Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(27; "Cashed in Location Code"; Code[10])
        {
            Caption = 'Cashed in Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(30; "Cashed External"; Boolean)
        {
            Caption = 'Cashed External';
            DataClassification = CustomerContent;
        }
        field(32; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
        }
        field(33; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
        field(34; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            DataClassification = CustomerContent;
        }
        field(35; Reference; Text[50])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
        }
        field(36; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Customer Type" = CONST(Alm)) Customer."No."
            ELSE
            IF ("Customer Type" = CONST(Kontant)) Contact."No.";
            ValidateTableRelation = false;
        }
        field(37; Invoiced; Boolean)
        {
            Caption = 'Invoiced';
            DataClassification = CustomerContent;
        }
        field(38; "Invoiced by Document Type"; Option)
        {
            Caption = 'Invoiced by Document Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Offer,Order,Invoice,Creditnote,Requisition Worksheet';
            OptionMembers = Tilbud,Ordre,Faktura,Kreditnota,Rammeordre;
        }
        field(39; "Invoiced by Document No."; Code[20])
        {
            Caption = 'Invoiced by Document No.';
            DataClassification = CustomerContent;
        }
        field(40; "Cashed Externaly on Doc. No."; Code[20])
        {
            Caption = 'Cashed Externaly on Doc. No.';
            DataClassification = CustomerContent;
        }
        field(41; "Cashed Audit Roll Type"; Integer)
        {
            Caption = 'Cashed Audit Roll Type';
            DataClassification = CustomerContent;
        }
        field(42; "Cashed Audit Roll Line"; Integer)
        {
            Caption = 'Cashed Audit Roll Line';
            DataClassification = CustomerContent;
        }
        field(43; "Issuing Register No."; Code[10])
        {
            Caption = 'Issuing Cash Register No.';
            DataClassification = CustomerContent;
        }
        field(44; "Issuing Sales Ticket No."; Code[20])
        {
            Caption = 'Issuing Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(45; "Issuing Audit Roll Type"; Integer)
        {
            Caption = 'Issuing Audit Roll Type';
            DataClassification = CustomerContent;
        }
        field(46; "Issuing Audit Roll Line"; Integer)
        {
            Caption = 'Issuing Audit Roll Line';
            DataClassification = CustomerContent;
        }
        field(47; "External Gift Voucher"; Boolean)
        {
            Caption = 'External Gift Voucher';
            DataClassification = CustomerContent;
        }
        field(48; "Man. Change of Status Date"; Date)
        {
            Caption = 'Man. Change of Status Date';
            DataClassification = CustomerContent;
        }
        field(49; "Status Changed Man. by"; Code[20])
        {
            Caption = 'Status Changed Man. by';
            DataClassification = CustomerContent;
        }
        field(50; "Customer Type"; Option)
        {
            Caption = 'Customer Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Ordinary,Cash';
            OptionMembers = Alm,Kontant;
        }
        field(51; "Cashed in Store"; Code[20])
        {
            Caption = 'Cashed in Store';
            DataClassification = CustomerContent;
        }
        field(53; "External No."; Code[20])
        {
            Caption = 'External No.';
            DataClassification = CustomerContent;
        }
        field(54; "Canceling Salesperson"; Code[20])
        {
            Caption = 'Canceling Salesperson';
            DataClassification = CustomerContent;
        }
        field(55; "Created in Company"; Code[30])
        {
            Caption = 'Created in Company';
            DataClassification = CustomerContent;
        }
        field(56; "Offline - No."; Code[20])
        {
            Caption = 'Offline - No.';
            DataClassification = CustomerContent;
        }
        field(57; "Primary Key Length"; Integer)
        {
            Caption = 'Primary Key Length';
            DataClassification = CustomerContent;
        }
        field(58; Offline; Boolean)
        {
            Caption = 'Offline';
            DataClassification = CustomerContent;
        }
        field(59; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(60; "Cashed in Global Dim 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Cashed in Department Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(61; "Payment Type No."; Code[20])
        {
            Caption = 'Payment Type No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(62; "Exported date"; Date)
        {
            Caption = 'Exported the';
            DataClassification = CustomerContent;
        }
        field(63; "Secret Code"; Code[6])
        {
            Caption = 'Secret Code';
            DataClassification = CustomerContent;
        }
        field(70; "Cashed POS Entry No."; Integer)
        {
            Caption = 'Cashed POS Entry No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.38 [302766]';
            TableRelation = "NPR POS Entry";
        }
        field(71; "Cashed POS Payment Line No."; Integer)
        {
            Caption = 'Cashed POS Payment Line No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.38 [302766]';
            TableRelation = "NPR POS Payment Line"."Line No." WHERE("POS Entry No." = FIELD("Cashed POS Entry No."));
        }
        field(72; "Cashed POS Unit No."; Code[10])
        {
            Caption = 'Cashed POS Unit No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.38 [302766]';
        }
        field(75; "Issuing POS Entry No"; Integer)
        {
            Caption = 'Issuing POS Entry No';
            DataClassification = CustomerContent;
            Description = 'NPR5.38 [302766]';
            TableRelation = "NPR POS Entry";
        }
        field(76; "Issuing POS Sale Line No."; Integer)
        {
            Caption = 'Issuing POS Sale Line No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.38 [302766]';
            TableRelation = "NPR POS Sales Line"."Line No." WHERE("POS Entry No." = FIELD("Issuing POS Entry No"));
        }
        field(77; "Issuing POS Unit No."; Code[10])
        {
            Caption = 'Issuing POS Unit No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.38 [302766]';
        }
        field(6014400; "No. Printed"; Integer)
        {
            Caption = 'No. Printed';
            DataClassification = CustomerContent;
        }
        field(6014401; Comment; Boolean)
        {
            CalcFormula = Exist("NPR Retail Comment" WHERE("Table ID" = CONST(6014410),
                                                        "No." = FIELD("No.")));
            Caption = 'Comment';
            FieldClass = FlowField;
        }
        field(6151400; "Voucher No."; Code[20])
        {
            Caption = 'Voucher No.';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151405; "External Gift Voucher No."; Code[10])
        {
            Caption = 'External Credit Voucher No.';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151410; "External Reference No."; Code[30])
        {
            Caption = 'External Reference No.';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151415; "Expire Date"; Date)
        {
            Caption = 'Expire Date';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151420; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
            TableRelation = Currency;
        }
        field(6151425; "Sales Order No."; Code[20])
        {
            Caption = 'Sales Order No.';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151430; "Gift Voucher Message"; BLOB)
        {
            Caption = 'Message';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; Status, "Issue Date", "Primary Key Length")
        {
            SumIndexFields = Amount;
        }
        key(Key3; "Sales Ticket No.")
        {
        }
        key(Key4; Status, "Issue Date", "Cashed Date", "External Gift Voucher")
        {
            SumIndexFields = Amount;
        }
        key(Key5; Status, "Cashed Date")
        {
        }
        key(Key6; Name, "Primary Key Length")
        {
        }
        key(Key7; "Primary Key Length")
        {
        }
        key(Key8; "Offline - No.")
        {
        }
        key(Key9; Status, "Issue Date", "Cashed Date", "External Gift Voucher", "Location Code")
        {
            SumIndexFields = Amount;
        }
        key(Key10; "External Reference No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        RetailSetup.Get;
        if "No." = '' then begin
            if "External Gift Voucher" then begin
                RetailSetup.TestField("Foreign Gift Voucher no.Series");
                NoSeriesMgt.InitSeries(RetailSetup."Foreign Gift Voucher no.Series", xRec."No. Series", 0D, "No.", "No. Series");
                //-NPR70.00.01.02
                "Voucher No." := "No.";
                //+NPR70.00.01.02
            end else begin
                RetailSetup.TestField("Gift Voucher No. Management");
                NoSeriesMgt.InitSeries(RetailSetup."Gift Voucher No. Management", xRec."No. Series", 0D, "No.", "No. Series");
                //-NPR70.00.01.02
                "Voucher No." := "No.";
                //+NPR70.00.01.02
                if RetailSetup."EAN Mgt. Gift voucher" <> '' then
                    "No." := Utility.CreateEAN("No.", Format(RetailSetup."EAN Mgt. Gift voucher"));
            end;
        end;

        /* COMMON GIFT VOUCHER ---------------------------------------------------------------- */
        if RetailSetup."Use I-Comm" and (not "External Gift Voucher") then begin
            RecIComm.Get;
            if RecIComm."Company - Clearing" <> '' then
                RetailCodeunit.GiftVoucherCommonCreate(Rec);
            if RecIComm."Clearing - SQL" then
                IComm.CreateGiftVoucherSQL(Rec);  //have to be moved to another CU
        end;


        "Primary Key Length" := StrLen("No.");
        GenerateSecretCode;

    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today;
        "Primary Key Length" := StrLen("No.");

        RetailCodeunit.GiftVoucherCommonOfflineModify(Rec);
    end;

    var
        GiftVoucher: Record "NPR Gift Voucher";
        RetailSetup: Record "NPR Retail Setup";
        PostCode: Record "Post Code";
        RecIComm: Record "NPR I-Comm";
        IComm: Codeunit "NPR I-Comm";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        RetailCodeunit: Codeunit "NPR Retail Table Code";
        Utility: Codeunit "NPR Utility";

    procedure Assistedit(): Boolean
    var
        GiftVoucher2: Record "NPR Gift Voucher";
    begin
        with GiftVoucher do begin
            GiftVoucher := Rec;
            RetailSetup.Get;
            if "External Gift Voucher" then begin
                RetailSetup.TestField("Foreign Gift Voucher no.Series");
                if NoSeriesMgt.SelectSeries(RetailSetup."Foreign Gift Voucher no.Series", GiftVoucher2."No. Series", "No. Series") then begin
                    NoSeriesMgt.SetSeries("No.");
                    Rec := GiftVoucher;
                    exit(true);
                end;
            end else begin
                RetailSetup.TestField("Gift Voucher No. Management");
                if NoSeriesMgt.SelectSeries(RetailSetup."Gift Voucher No. Management", GiftVoucher2."No. Series", "No. Series") then begin
                    NoSeriesMgt.SetSeries("No.");
                    Rec := GiftVoucher;
                    exit(true);
                end;
            end;
        end;
    end;

    procedure PrintGiftVoucher(ViewDemand: Boolean; Copy2: Boolean)
    var
        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        RecRef: RecordRef;
        RetailFormCode: Codeunit "NPR Retail Form Code";
    begin
        FindFirst;
        SetRecFilter;

        RecRef.GetTable(Rec);
        RetailReportSelectionMgt.SetRequestWindow(ViewDemand);
        RetailReportSelectionMgt.SetRegisterNo(RetailFormCode.FetchRegisterNumber());
        RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Gift Voucher");
    end;

    procedure CreateInvoice()
    var
        NFRetailCode: Codeunit "NPR NF Retail Code";
    begin
        //CreateInvoice
        NFRetailCode.TR409CreateInvFromGiftVoucher(Rec);
    end;

    procedure CreateFromAuditRoll(var AuditRoll: Record "NPR Audit Roll")
    begin
        //CreateFromAuditRoll
        "Issuing Register No." := AuditRoll."Register No.";
        "Issuing Sales Ticket No." := AuditRoll."Sales Ticket No.";
        "Issuing Audit Roll Type" := AuditRoll."Sale Type";
        "Issuing Audit Roll Line" := AuditRoll."Line No.";
        "Salesperson Code" := AuditRoll."Salesperson Code";
        Status := Status::Open;
    end;

    procedure RedeemFromSaleLinePOS(var SaleLinePOS: Record "NPR Sale Line POS"; SalespersonCode: Code[20]; LineNo: Integer)
    var
        AuditRoll: Record "NPR Audit Roll";
        ErrRedeemed: Label 'The gift card %1 has already been redeemed on the %2';
        RecIcomm: Record "NPR I-Comm";
        SaleHeader: Record "NPR Sale POS";
        FormCode: Codeunit "NPR Retail Form Code";
        Amount2: Decimal;
        PaymentType: Option Gift,Credit;
        ErrAmount: Label 'The amount at Gift Voucher %1 does not match the Payment Line';
    begin
        //RedeemFromSaleLinePOS
        RetailSetup.Get;

        /*IF Opsætning."Tillad I-Comm" THEN BEGIN
          recIComm.GET;
          IF recIComm."Company - Clearing" <> '' THEN BEGIN
            IF NOT ( IComm.DBGavekort( Rec, TRUE, TRUE, TRUE, TestBel¢b ) = Status::Åben ) THEN
              ERROR( ErrIndl¢stDB, Nummer );
            Status := Status::Indl¢st;
            IComm.DBGavekort( Rec, FALSE, TRUE, TRUE, TestBel¢b );
            IF TestBel¢b <> EkspLinie."Bel¢b inkl. moms" THEN
              ERROR( ErrDBAmount, TestBel¢b );
          END ELSE
            IF Status = Status::Indl¢st THEN
              ERROR( ErrIndl¢st, Nummer, "Indl¢st den" );
        END ELSE BEGIN
            IF Status = Status::Indl¢st THEN
              ERROR( ErrIndl¢st, Nummer, "Indl¢st den" );
        END;                                                 */

        if Status = Status::Cashed then
            Error(ErrRedeemed, "No.", "Cashed Date");

        Status := Status::Cashed;

        if "External Gift Voucher" then begin
            "Register No." := SaleLinePOS."Register No.";
            "Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
            Modify;
        end;

        "Cashed on Register No." := SaleLinePOS."Register No.";
        "Cashed on Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        "Cashed Date" := SaleLinePOS.Date;
        "Cashed Salesperson" := SalespersonCode;
        "Cashed in Global Dim 1 Code" := SaleLinePOS."Shortcut Dimension 1 Code";
        "Cashed in Location Code" := SaleLinePOS."Location Code";
        "Cashed Audit Roll Type" := AuditRoll."Sale Type"::Payment;
        "Cashed Audit Roll Line" := LineNo;
        "Cashed in Store" := RetailSetup."Company No.";
        "Payment Type No." := SaleLinePOS."No.";

        if RetailSetup."Use I-Comm" then begin
            RecIcomm.Get;
            if RecIcomm."Company - Clearing" <> '' then begin
                SaleHeader.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.");
                Amount2 := FormCode.GetGCVoAmount(SaleLinePOS, PaymentType::Gift, false);
                if Amount2 <> SaleLinePOS."Amount Including VAT" then begin
                    if Amount2 <> 0 then
                        Error(ErrAmount, SaleLinePOS."Foreign No.");
                end else begin
                    RetailCodeunit.GiftVoucherCommonValidate(SaleHeader, "No.", Status::Cashed);
                end;
            end;
        end;

    end;

    procedure FindIssuedAuditRoll()
    var
        AuditRoll: Record "NPR Audit Roll";
    begin
        //FindIssuedAuditRoll

        AuditRoll.Reset;
        AuditRoll.SetRange("Register No.", "Issuing Register No.");
        AuditRoll.SetRange("Sales Ticket No.", "Issuing Sales Ticket No.");
        AuditRoll.SetFilter(Type, '<>%1', AuditRoll.Type::"Open/Close");
        AuditRoll.SetRange("Sale Type", "Issuing Audit Roll Type");
        AuditRoll.SetRange("Line No.", "Issuing Audit Roll Line");
        AuditRoll.Find('-');
        /*FORMISSUE
        NaviForm.SetDoc( RevRulle."Sale Date", RevRulle."Posted Doc. No." );
        NaviForm.SetReceiptNo("Issuing Sales Ticket No.");
        NaviForm.RUN;*/

    end;

    procedure FindRedeemedAuditRoll()
    var
        AuditRoll: Record "NPR Audit Roll";
    begin
        //FindRedeemedAuditRoll
        AuditRoll.Reset;
        AuditRoll.SetRange("Register No.", "Cashed on Register No.");
        AuditRoll.SetRange("Sales Ticket No.", "Cashed on Sales Ticket No.");
        AuditRoll.SetRange("Sale Type", "Cashed Audit Roll Type");
        AuditRoll.SetRange("Line No.", "Cashed Audit Roll Line");
        AuditRoll.Find('-');
        /*FORMISSUE
        NaviForm.SetDoc( RevRulle."Sale Date", RevRulle."Posted Doc. No." );
        NaviForm.SetReceiptNo("Cashed on Sales Ticket No.");
        NaviForm.RUN;*/

    end;

    procedure RedeemF4()
    var
        ErrGift: Label 'Gift voucher allready checked in.';
    begin
        //RedeemF4
        if Status = Status::Cashed then
            Error(ErrGift);

        Status := Status::Cashed;
        "Cashed on Sales Ticket No." := 'F4';
        "Cashed Date" := WorkDate;
        Modify(true);
    end;

    procedure GenerateSecretCode()
    begin
        Randomize;
        "Secret Code" := Format(Random(999999));

        while StrLen("Secret Code") < 6 do
            "Secret Code" := '0' + "Secret Code";
    end;

    procedure CreateFromPOSSalesLine(var POSSalesLine: Record "NPR POS Sales Line")
    begin
        //-NPR5.38 [302766]
        "Issuing POS Entry No" := POSSalesLine."POS Entry No.";
        "Issuing POS Sale Line No." := POSSalesLine."Line No.";
        "Issuing POS Unit No." := POSSalesLine."POS Unit No.";
        "Issuing Sales Ticket No." := POSSalesLine."Document No.";
        "Salesperson Code" := POSSalesLine."Salesperson Code";
        Status := Status::Open;
        //-NPR5.38 [302766]
    end;

    procedure LinkToPOSPaymentLine(var POSPaymentLine: Record "NPR POS Payment Line")
    begin
        //-NPR5.38 [302766]
        "Cashed POS Entry No." := POSPaymentLine."POS Entry No.";
        "Cashed POS Payment Line No." := POSPaymentLine."Line No.";
        "Cashed POS Unit No." := POSPaymentLine."POS Unit No.";
        //-NPR5.38 [302766]
    end;
}

