table 6014408 "NPR Credit Voucher"
{
    // //NPR2.2m - Ohm - ny n¢gle "indl¢st den"
    // 
    // //NPR3.1c - NE - Tilf¢jet det boolske flowfield comment.
    // 
    // //NPK1.0 , 13-03-12, job 118881, JS - Modified the print function, so i only prints for a specific register.
    // NPR70.00.01.03/MH/20150113  CASE 199932 Removed Web references (WEB1.00).
    // NPR70.00.01.04/MH/20150205  CASE 199932 Original No. from No. Series is transfered to "Voucher No." OnInsert.
    // MAG1.06/TS/20150206  CASE 201682 Adding Magento Hooks - Changed field Status Caption
    // NPR4.15/MMV/20151007 CASE 223991 Added handling of printing credit vouchers with label module.
    //                                  Fixed no filter attempt on register no. when printing through codeunit.
    // NPR4.16/MMV/20151112 CASE 227186 Changed report call to use the correct record.
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

    Caption = 'Credit Voucher';
    DataClassification = CustomerContent;
    LookupPageID = "NPR Credit Voucher List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
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
                TempAmount: Decimal;
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
                        IComm.DBCreditVoucher(Rec, false, true, true, TempAmount);
                end;
            end;
        }
        field(9; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
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
        field(12; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
            TableRelation = "Post Code";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin

                PostCode.Reset;
                PostCode.SetRange(Code, "Post Code");
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
        field(32; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
        field(33; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            DataClassification = CustomerContent;
        }
        field(34; Reference; Text[50])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
        }
        field(35; Nummerserie; Code[10])
        {
            Caption = 'Numberserie';
            DataClassification = CustomerContent;
        }
        field(36; "Customer No"; Code[20])
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
        field(38; "Invoiced on enclosure"; Option)
        {
            Caption = 'Invoiced on enclosure';
            DataClassification = CustomerContent;
            OptionCaption = 'Offer,Order,Invoice,Creditnote,Requisition Worksheet';
            OptionMembers = Tilbud,Ordre,Faktura,Kreditnota,Rammeordre;
        }
        field(39; "Invoiced on enclosure no."; Code[20])
        {
            Caption = 'Invoiced on enclosure no.';
            DataClassification = CustomerContent;
            TableRelation = "Sales Header"."No." WHERE("Document Type" = FIELD("Invoiced on enclosure"));
        }
        field(40; "Checked external via enclosure"; Code[20])
        {
            Caption = 'Checked external via enclosure No';
            DataClassification = CustomerContent;
        }
        field(41; "Issued on Drawer No"; Code[10])
        {
            Caption = 'Issued on Drawer No';
            DataClassification = CustomerContent;
        }
        field(42; "Issued on Ticket No"; Code[20])
        {
            Caption = 'Issued on Ticket No';
            DataClassification = CustomerContent;
        }
        field(43; "Issued Audit Roll Type"; Integer)
        {
            Caption = 'Issued Audit Roll Type';
            DataClassification = CustomerContent;
        }
        field(44; "Issued Audit Roll Line"; Integer)
        {
            Caption = 'Issued Audit Roll Line';
            DataClassification = CustomerContent;
        }
        field(45; "Checked Audit"; Integer)
        {
            Caption = 'Checked Audit';
            DataClassification = CustomerContent;
        }
        field(46; "Check Audit Roll Line"; Integer)
        {
            Caption = 'Check Audit Roll Line';
            DataClassification = CustomerContent;
        }
        field(47; "External Credit Voucher"; Boolean)
        {
            Caption = 'External Gift Voucher';
            DataClassification = CustomerContent;
        }
        field(48; "Status manually changed on"; Date)
        {
            Caption = 'Status manually changed on';
            DataClassification = CustomerContent;
        }
        field(49; "Status manually changed by"; Code[20])
        {
            Caption = 'Status manually changed by';
            DataClassification = CustomerContent;
        }
        field(50; "Customer Type"; Option)
        {
            Caption = 'Customer Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Ordinary,Cash';
            OptionMembers = Alm,Kontant;
        }
        field(51; "Cashed in store"; Code[30])
        {
            Caption = 'Cashed in store';
            DataClassification = CustomerContent;
        }
        field(53; "External no"; Code[20])
        {
            Caption = 'Alien no';
            DataClassification = CustomerContent;
        }
        field(54; "Cancelled by salesperson"; Code[20])
        {
            Caption = 'Cancelled by salesperson';
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
        field(6151405; "External Credit Voucher No."; Code[10])
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
        key(Key4; Status, "Issue Date", "Cashed Date", "External Credit Voucher")
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
        key(Key9; Status, "Issue Date", "Cashed Date", "External Credit Voucher", "Location Code")
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
            RetailSetup.TestField("Credit Voucher No. Management");
            if "External Credit Voucher" then begin
                NoSeriesMgt.InitSeries(RetailSetup."Foreign Credit Voucher No.Seri", xRec.Nummerserie, 0D, "No.", Nummerserie);
                //-NPR70.00.01.04
                "Voucher No." := "No.";
                //+NPR70.00.01.04
            end else begin
                NoSeriesMgt.InitSeries(RetailSetup."Credit Voucher No. Management", xRec.Nummerserie, 0D, "No.", Nummerserie);
                //-NPR70.00.01.04
                "Voucher No." := "No.";
                //+NPR70.00.01.04
                if RetailSetup."EAN Mgt. Credit voucher" <> '' then
                    "No." := Utility.CreateEAN("No.", Format(RetailSetup."EAN Mgt. Credit voucher"));
            end;
        end;

        if RetailSetup."Use I-Comm" and (not "External Credit Voucher") then begin
            RecIComm.Get;
            if RecIComm."Company - Clearing" <> '' then
                RetailCodeunit.CreditVoucherCommonCreate(Rec);
        end;

        "Primary Key Length" := StrLen("No.");
    end;

    trigger OnModify()
    var
        TempAmount: Decimal;
    begin
        "Last Date Modified" := Today;
        RetailSetup.Get;
        if RetailSetup."Use I-Comm" then begin
            RecIComm.Get;
            if RecIComm."Company - Clearing" <> '' then
                IComm.DBCreditVoucher(Rec, false, false, true, TempAmount);
        end;

        "Primary Key Length" := StrLen("No.");

        RetailCodeunit.CreditVoucherCommonModify(Rec);
    end;

    var
        RetailSetup: Record "NPR Retail Setup";
        PostCode: Record "Post Code";
        RecIComm: Record "NPR I-Comm";
        Utility: Codeunit "NPR Utility";
        IComm: Codeunit "NPR I-Comm";
        RetailCodeunit: Codeunit "NPR Retail Table Code";
        NoSeriesMgt: Codeunit NoSeriesManagement;

    procedure PrintCreditVoucher(ViewDemand: Boolean; Copy2: Boolean)
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
        //-NPR5.29 [241549]
        // IF Kopi THEN
        //  RetailReportSelectionMgt.RunObjects(RecRef,ReportSelectionRetail."Report Type"::"7")
        // ELSE
        //+NPR5.29 [241549]
        RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Credit Voucher");
    end;

    procedure CreateInvoice()
    var
        NFRetailCode: Codeunit "NPR NF Retail Code";
    begin
        //CreateInvoice
        NFRetailCode.TR408CreateInvFromCreditVoucher(Rec);
    end;

    procedure RedeemF4()
    var
        ErrCredit: Label 'This Credit Voucher has already been cashed';
    begin
        //RedeemF4
        if Status = Status::Cashed then
            Error(ErrCredit);

        Status := Status::Cashed;
        "Cashed on Sales Ticket No." := 'F4';
        "Cashed Date" := WorkDate;
        Modify;
    end;

    procedure FindIssuedAuditRoll()
    var
        AuditRoll: Record "NPR Audit Roll";
    begin
        //FindIssuedAuditRoll
        AuditRoll.SetRange("Register No.", "Issued on Drawer No");
        AuditRoll.SetRange("Sales Ticket No.", "Issued on Ticket No");
        AuditRoll.SetRange("Sale Type", "Issued Audit Roll Type");
        AuditRoll.SetRange("Line No.", "Issued Audit Roll Line");
        AuditRoll.Find('-');
        /*FORMISSUE
        NaviForm.SetDoc( RevRulle."Sale Date", RevRulle."Posted Doc. No." );
        NaviForm.SetReceiptNo("Issued on Ticket No");
        NaviForm.RUN;*/

    end;

    procedure FindRedeemedAuditRoll()
    var
        AuditRoll: Record "NPR Audit Roll";
    begin
        //FindRedeemedAuditRoll
        AuditRoll.SetRange("Register No.", "Cashed on Register No.");
        AuditRoll.SetRange("Sales Ticket No.", "Cashed on Sales Ticket No.");
        AuditRoll.SetRange("Sale Type", "Checked Audit");
        AuditRoll.SetRange("Line No.", "Check Audit Roll Line");
        AuditRoll.Find('-');
        /*FORMISSUE
        NaviForm.SetDoc( RevRulle."Sale Date", RevRulle."Posted Doc. No." );
        NaviForm.SetReceiptNo("Cashed on Sales Ticket No.");
        NaviForm.RUN;*/

    end;

    procedure CreateFromAuditRoll(var AuditRoll: Record "NPR Audit Roll")
    begin
        //CreateFromAuditRoll
        "Issued on Drawer No" := AuditRoll."Register No.";
        "Issued on Ticket No" := AuditRoll."Sales Ticket No.";
        "Issued Audit Roll Type" := AuditRoll."Sale Type";
        "Issued Audit Roll Line" := AuditRoll."Line No.";
        Status := Status::Open;
    end;

    procedure RedeemFromSaleLinePOS(var SaleLinePOS: Record "NPR Sale Line POS"; SalespersonCode: Code[20]; LineNo: Integer)
    var
        AuditRoll: Record "NPR Audit Roll";
        ErrRedeemed: Label 'The voucher %1 has already been redeemed on the %2';
        SaleHeader: Record "NPR Sale POS";
        RetailCode: Codeunit "NPR Retail Table Code";
        FormCode: Codeunit "NPR Retail Form Code";
        Amount2: Decimal;
        PaymentType: Option Gift,Credit;
        ErrAmount: Label 'The amount at Credit Voucher %1 does not match the Payment Line';
    begin
        //RedeemFromSaleLinePOS
        RetailSetup.Get;

        if Status = Status::Cashed then
            Error(ErrRedeemed, "No.", "Cashed Date");

        Status := Status::Cashed;
        "Cashed on Register No." := SaleLinePOS."Register No.";
        "Cashed on Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        "Cashed Date" := SaleLinePOS.Date;
        "Cashed Salesperson" := SalespersonCode;
        "Cashed in Global Dim 1 Code" := SaleLinePOS."Shortcut Dimension 1 Code";
        "Cashed in Location Code" := SaleLinePOS."Location Code";
        "Checked Audit" := AuditRoll."Sale Type"::Payment;
        "Check Audit Roll Line" := LineNo;
        "Cashed in store" := RetailSetup."Company No.";
        "Payment Type No." := SaleLinePOS."No.";

        if RetailSetup."Use I-Comm" then begin
            RecIComm.Get;
            if RecIComm."Company - Clearing" <> '' then begin
                SaleHeader.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.");
                Amount2 := FormCode.GetGCVoAmount(SaleLinePOS, PaymentType::Credit, false);
                if Amount2 <> SaleLinePOS."Amount Including VAT" then begin
                    if Amount2 <> 0 then
                        Error(ErrAmount, SaleLinePOS."Foreign No.")
                end else begin
                    RetailCode.CreditVoucherCommonValidate(SaleHeader, "No.", Status::Cashed);
                end;
            end;
        end;
    end;

    procedure CreateFromPOSSalesLine(var POSSalesLine: Record "NPR POS Sales Line")
    begin
        //-NPR5.38 [302766]
        "Issuing POS Entry No" := POSSalesLine."POS Entry No.";
        "Issuing POS Sale Line No." := POSSalesLine."Line No.";
        "Issuing POS Unit No." := POSSalesLine."POS Unit No.";
        "Issued on Ticket No" := POSSalesLine."Document No.";
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

