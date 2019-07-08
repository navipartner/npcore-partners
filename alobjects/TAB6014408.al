table 6014408 "Credit Voucher"
{
    // //NPR2.2m - Ohm - ny n�gle "indl�st den"
    // 
    // //NPR3.1c - NE - Tilf�jet det boolske flowfield comment.
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
    LookupPageID = "Credit Voucher List";

    fields
    {
        field(1;"No.";Code[20])
        {
            Caption = 'No.';
        }
        field(2;"Register No.";Code[10])
        {
            Caption = 'Cash Register No.';
        }
        field(3;"Sales Ticket No.";Code[20])
        {
            Caption = 'Sales Ticket No.';
        }
        field(4;"Issue Date";Date)
        {
            Caption = 'Issue Date';
        }
        field(5;Salesperson;Code[10])
        {
            Caption = 'Salesperson';
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(6;"Shortcut Dimension 1 Code";Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1));
        }
        field(7;"Location Code";Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(8;Status;Option)
        {
            Caption = 'Status';
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
                    IComm.DBCreditVoucher(Rec,false,true,true,TempAmount);
                end;
            end;
        }
        field(9;Amount;Decimal)
        {
            Caption = 'Amount';
            MaxValue = 9999999;
        }
        field(10;Name;Text[50])
        {
            Caption = 'Name';
            Description = 'NPR5.38';
        }
        field(11;Address;Text[50])
        {
            Caption = 'Address';
            Description = 'NPR5.38';
        }
        field(12;"Post Code";Code[20])
        {
            Caption = 'Post Code';
            TableRelation = "Post Code";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin

                PostCode.Reset;
                PostCode.SetRange(Code,"Post Code");
                if PostCode.Find('-') then
                  City := PostCode.City;
            end;
        }
        field(13;City;Text[50])
        {
            Caption = 'City';
            Description = 'NPR5.38';
        }
        field(22;"Cashed on Register No.";Code[10])
        {
            Caption = 'Cashed on Cash Register No.';
        }
        field(23;"Cashed on Sales Ticket No.";Code[20])
        {
            Caption = 'Cashed on Sales Ticket No.';
        }
        field(24;"Cashed Date";Date)
        {
            Caption = 'Cashed Date';
        }
        field(25;"Cashed Salesperson";Code[10])
        {
            Caption = 'Cashed Salesperson';
            TableRelation = "Salesperson/Purchaser";
        }
        field(26;"Cashed in Global Dim 1 Code";Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Cashed in Department Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1));
        }
        field(27;"Cashed in Location Code";Code[10])
        {
            Caption = 'Cashed in Location Code';
            TableRelation = Location;
        }
        field(30;"Cashed External";Boolean)
        {
            Caption = 'Cashed External';
        }
        field(32;Blocked;Boolean)
        {
            Caption = 'Blocked';
        }
        field(33;"Last Date Modified";Date)
        {
            Caption = 'Last Date Modified';
        }
        field(34;Reference;Text[50])
        {
            Caption = 'Reference';
        }
        field(35;Nummerserie;Code[10])
        {
            Caption = 'Numberserie';
        }
        field(36;"Customer No";Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = IF ("Customer Type"=CONST(Alm)) Customer."No."
                            ELSE IF ("Customer Type"=CONST(Kontant)) Contact."No.";
            ValidateTableRelation = false;
        }
        field(37;Invoiced;Boolean)
        {
            Caption = 'Invoiced';
        }
        field(38;"Invoiced on enclosure";Option)
        {
            Caption = 'Invoiced on enclosure';
            OptionCaption = 'Offer,Order,Invoice,Creditnote,Requisition Worksheet';
            OptionMembers = Tilbud,Ordre,Faktura,Kreditnota,Rammeordre;
        }
        field(39;"Invoiced on enclosure no.";Code[20])
        {
            Caption = 'Invoiced on enclosure no.';
            TableRelation = "Sales Header"."No." WHERE ("Document Type"=FIELD("Invoiced on enclosure"));
        }
        field(40;"Checked external via enclosure";Code[20])
        {
            Caption = 'Checked external via enclosure No';
        }
        field(41;"Issued on Drawer No";Code[10])
        {
            Caption = 'Issued on Drawer No';
        }
        field(42;"Issued on Ticket No";Code[20])
        {
            Caption = 'Issued on Ticket No';
        }
        field(43;"Issued Audit Roll Type";Integer)
        {
            Caption = 'Issued Audit Roll Type';
        }
        field(44;"Issued Audit Roll Line";Integer)
        {
            Caption = 'Issued Audit Roll Line';
        }
        field(45;"Checked Audit";Integer)
        {
            Caption = 'Checked Audit';
        }
        field(46;"Check Audit Roll Line";Integer)
        {
            Caption = 'Check Audit Roll Line';
        }
        field(47;"External Credit Voucher";Boolean)
        {
            Caption = 'External Gift Voucher';
        }
        field(48;"Status manually changed on";Date)
        {
            Caption = 'Status manually changed on';
        }
        field(49;"Status manually changed by";Code[20])
        {
            Caption = 'Status manually changed by';
        }
        field(50;"Customer Type";Option)
        {
            Caption = 'Customer Type';
            OptionCaption = 'Ordinary,Cash';
            OptionMembers = Alm,Kontant;
        }
        field(51;"Cashed in store";Code[30])
        {
            Caption = 'Cashed in store';
        }
        field(53;"External no";Code[20])
        {
            Caption = 'Alien no';
        }
        field(54;"Cancelled by salesperson";Code[20])
        {
            Caption = 'Cancelled by salesperson';
        }
        field(55;"Created in Company";Code[30])
        {
            Caption = 'Created in Company';
        }
        field(56;"Offline - No.";Code[20])
        {
            Caption = 'Offline - No.';
        }
        field(57;"Primary Key Length";Integer)
        {
            Caption = 'Primary Key Length';
        }
        field(58;Offline;Boolean)
        {
            Caption = 'Offline';
        }
        field(59;"Shortcut Dimension 2 Code";Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(2));
        }
        field(60;"Cashed in Global Dim 2 Code";Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Cashed in Department Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(2));
        }
        field(61;"Payment Type No.";Code[20])
        {
            Caption = 'Payment Type No.';
            NotBlank = true;
        }
        field(62;"Exported date";Date)
        {
            Caption = 'Exported the';
        }
        field(70;"Cashed POS Entry No.";Integer)
        {
            Caption = 'Cashed POS Entry No.';
            Description = 'NPR5.38 [302766]';
            TableRelation = "POS Entry";
        }
        field(71;"Cashed POS Payment Line No.";Integer)
        {
            Caption = 'Cashed POS Payment Line No.';
            Description = 'NPR5.38 [302766]';
            TableRelation = "POS Payment Line"."Line No." WHERE ("POS Entry No."=FIELD("Cashed POS Entry No."));
        }
        field(72;"Cashed POS Unit No.";Code[10])
        {
            Caption = 'Cashed POS Unit No.';
            Description = 'NPR5.38 [302766]';
        }
        field(75;"Issuing POS Entry No";Integer)
        {
            Caption = 'Issuing POS Entry No';
            Description = 'NPR5.38 [302766]';
            TableRelation = "POS Entry";
        }
        field(76;"Issuing POS Sale Line No.";Integer)
        {
            Caption = 'Issuing POS Sale Line No.';
            Description = 'NPR5.38 [302766]';
            TableRelation = "POS Sales Line"."Line No." WHERE ("POS Entry No."=FIELD("Issuing POS Entry No"));
        }
        field(77;"Issuing POS Unit No.";Code[10])
        {
            Caption = 'Issuing POS Unit No.';
            Description = 'NPR5.38 [302766]';
        }
        field(6014400;"No. Printed";Integer)
        {
            Caption = 'No. Printed';
        }
        field(6014401;Comment;Boolean)
        {
            CalcFormula = Exist("Retail Comment" WHERE ("Table ID"=CONST(6014410),
                                                        "No."=FIELD("No.")));
            Caption = 'Comment';
            FieldClass = FlowField;
        }
        field(6151400;"Voucher No.";Code[20])
        {
            Caption = 'Voucher No.';
            Description = 'MAG2.00';
        }
        field(6151405;"External Credit Voucher No.";Code[10])
        {
            Caption = 'External Credit Voucher No.';
            Description = 'MAG2.00';
        }
        field(6151410;"External Reference No.";Code[30])
        {
            Caption = 'External Reference No.';
            Description = 'MAG2.00';
        }
        field(6151415;"Expire Date";Date)
        {
            Caption = 'Expire Date';
            Description = 'MAG2.00';
        }
        field(6151420;"Currency Code";Code[10])
        {
            Caption = 'Currency Code';
            Description = 'MAG2.00';
            TableRelation = Currency;
        }
        field(6151425;"Sales Order No.";Code[20])
        {
            Caption = 'Sales Order No.';
            Description = 'MAG2.00';
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
        key(Key2;Status,"Issue Date","Primary Key Length")
        {
            SumIndexFields = Amount;
        }
        key(Key3;"Sales Ticket No.")
        {
        }
        key(Key4;Status,"Issue Date","Cashed Date","External Credit Voucher")
        {
            SumIndexFields = Amount;
        }
        key(Key5;Status,"Cashed Date")
        {
        }
        key(Key6;Name,"Primary Key Length")
        {
        }
        key(Key7;"Primary Key Length")
        {
        }
        key(Key8;"Offline - No.")
        {
        }
        key(Key9;Status,"Issue Date","Cashed Date","External Credit Voucher","Location Code")
        {
            SumIndexFields = Amount;
        }
        key(Key10;"External Reference No.")
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
            NoSeriesMgt.InitSeries(RetailSetup."Foreign Credit Voucher No.Seri",xRec.Nummerserie,0D,"No.",Nummerserie);
            //-NPR70.00.01.04
            "Voucher No." := "No.";
            //+NPR70.00.01.04
          end else begin
            NoSeriesMgt.InitSeries(RetailSetup."Credit Voucher No. Management",xRec.Nummerserie,0D,"No.",Nummerserie);
            //-NPR70.00.01.04
            "Voucher No." := "No.";
            //+NPR70.00.01.04
            if RetailSetup."EAN Mgt. Credit voucher" <> '' then
              "No." := Utility.CreateEAN("No.",Format(RetailSetup."EAN Mgt. Credit voucher"));
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
            IComm.DBCreditVoucher(Rec,false,false,true,TempAmount);
        end;

        "Primary Key Length" := StrLen("No.");

        RetailCodeunit.CreditVoucherCommonModify(Rec);
    end;

    var
        RetailSetup: Record "Retail Setup";
        PostCode: Record "Post Code";
        RecIComm: Record "I-Comm";
        Utility: Codeunit Utility;
        IComm: Codeunit "I-Comm";
        RetailCodeunit: Codeunit "Retail Table Code";
        NoSeriesMgt: Codeunit NoSeriesManagement;

    procedure PrintCreditVoucher(ViewDemand: Boolean;Copy2: Boolean)
    var
        RetailReportSelectionMgt: Codeunit "Retail Report Selection Mgt.";
        ReportSelectionRetail: Record "Report Selection Retail";
        RecRef: RecordRef;
        RetailFormCode: Codeunit "Retail Form Code";
    begin
        FindFirst;
        SetRecFilter;

        RecRef.GetTable(Rec);
        RetailReportSelectionMgt.SetRequestWindow(ViewDemand);
        RetailReportSelectionMgt.SetRegisterNo(RetailFormCode.FetchRegisterNumber() );
        //-NPR5.29 [241549]
        // IF Kopi THEN
        //  RetailReportSelectionMgt.RunObjects(RecRef,ReportSelectionRetail."Report Type"::"7")
        // ELSE
        //+NPR5.29 [241549]
        RetailReportSelectionMgt.RunObjects(RecRef,ReportSelectionRetail."Report Type"::"Credit Voucher");
    end;

    procedure CreateInvoice()
    var
        NFRetailCode: Codeunit "NF Retail Code";
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
        AuditRoll: Record "Audit Roll";
    begin
        //FindIssuedAuditRoll
        AuditRoll.SetRange("Register No.","Issued on Drawer No");
        AuditRoll.SetRange("Sales Ticket No.","Issued on Ticket No");
        AuditRoll.SetRange("Sale Type","Issued Audit Roll Type");
        AuditRoll.SetRange("Line No.","Issued Audit Roll Line");
        AuditRoll.Find('-');
        /*FORMISSUE
        NaviForm.SetDoc( RevRulle."Sale Date", RevRulle."Posted Doc. No." );
        NaviForm.SetReceiptNo("Issued on Ticket No");
        NaviForm.RUN;*/

    end;

    procedure FindRedeemedAuditRoll()
    var
        AuditRoll: Record "Audit Roll";
    begin
        //FindRedeemedAuditRoll
        AuditRoll.SetRange("Register No.","Cashed on Register No.");
        AuditRoll.SetRange("Sales Ticket No.","Cashed on Sales Ticket No.");
        AuditRoll.SetRange("Sale Type","Checked Audit");
        AuditRoll.SetRange("Line No.","Check Audit Roll Line");
        AuditRoll.Find('-');
        /*FORMISSUE
        NaviForm.SetDoc( RevRulle."Sale Date", RevRulle."Posted Doc. No." );
        NaviForm.SetReceiptNo("Cashed on Sales Ticket No.");
        NaviForm.RUN;*/

    end;

    procedure CreateFromAuditRoll(var AuditRoll: Record "Audit Roll")
    begin
        //CreateFromAuditRoll
        "Issued on Drawer No" := AuditRoll."Register No.";
        "Issued on Ticket No" := AuditRoll."Sales Ticket No.";
        "Issued Audit Roll Type" := AuditRoll."Sale Type";
        "Issued Audit Roll Line" := AuditRoll."Line No.";
        Status := Status::Open;
    end;

    procedure RedeemFromSaleLinePOS(var SaleLinePOS: Record "Sale Line POS";SalespersonCode: Code[20];LineNo: Integer)
    var
        AuditRoll: Record "Audit Roll";
        ErrRedeemed: Label 'The voucher %1 has already been redeemed on the %2';
        SaleHeader: Record "Sale POS";
        RetailCode: Codeunit "Retail Table Code";
        FormCode: Codeunit "Retail Form Code";
        Amount2: Decimal;
        PaymentType: Option Gift,Credit;
        ErrAmount: Label 'The amount at Credit Voucher %1 does not match the Payment Line';
    begin
        //RedeemFromSaleLinePOS
        RetailSetup.Get;

        if Status = Status::Cashed then
          Error(ErrRedeemed,"No.","Cashed Date");

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
              SaleHeader.Get(SaleLinePOS."Register No.",SaleLinePOS."Sales Ticket No.");
              Amount2 := FormCode.GetGCVoAmount(SaleLinePOS,PaymentType::Credit,false);
              if Amount2 <> SaleLinePOS."Amount Including VAT" then begin
                if Amount2 <> 0 then
                  Error(ErrAmount,SaleLinePOS."Foreign No.")
              end else begin
                RetailCode.CreditVoucherCommonValidate(SaleHeader,"No.",Status::Cashed );
              end;
            end;
        end;
    end;

    procedure CreateFromPOSSalesLine(var POSSalesLine: Record "POS Sales Line")
    begin
        //-NPR5.38 [302766]
        "Issuing POS Entry No" := POSSalesLine."POS Entry No.";
        "Issuing POS Sale Line No." := POSSalesLine."Line No.";
        "Issuing POS Unit No." := POSSalesLine."POS Unit No.";
        "Issued on Ticket No" :=  POSSalesLine."Document No.";
        Salesperson := POSSalesLine."Salesperson Code";
        Status := Status::Open;
        //-NPR5.38 [302766]
    end;

    procedure LinkToPOSPaymentLine(var POSPaymentLine: Record "POS Payment Line")
    begin
        //-NPR5.38 [302766]
        "Cashed POS Entry No." := POSPaymentLine."POS Entry No.";
        "Cashed POS Payment Line No." := POSPaymentLine."Line No.";
        "Cashed POS Unit No." := POSPaymentLine."POS Unit No.";
        //-NPR5.38 [302766]
    end;
}

