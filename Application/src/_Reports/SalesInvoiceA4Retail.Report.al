report 6014447 "NPR Sales Invoice A4 (Retail)"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Sales Invoice A4 (Retail).rdlc'; 
    UsageCategory = ReportsAndAnalysis; 
    ApplicationArea = All;
    Caption = 'Sales Invoice A4 (Retail)';
    dataset
    {
        dataitem("Sales Invoice Header"; "Sales Invoice Header")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "No. Printed";
            RequestFilterHeading = 'Posted sales invoice';
            column(No_SalesInvoiceHeader; "Sales Invoice Header"."No.")
            {
            }
            dataitem(KopiLoekke; "Integer")
            {
                DataItemTableView = SORTING(Number);
                column(Number_KopiLoekke; KopiLoekke.Number)
                {
                }
                dataitem(SideLoekke; "Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                    column(Number_SideLoekke; SideLoekke.Number)
                    {
                    }
                    column(TitleText; TitleText)
                    {
                    }
                    column(OutputNo; OutputNo)
                    {
                    }
                    column(companyaddr_1; Companyaddr[1])
                    {
                    }
                    column(companyaddr_2; Companyaddr[2])
                    {
                    }
                    column(companyaddr_3; Companyaddr[3])
                    {
                    }
                    column(companyaddr_4; Companyaddr[4])
                    {
                    }
                    column(companyaddr_5; Companyaddr[5])
                    {
                    }
                    column(companyaddr_6; Companyaddr[6])
                    {
                    }
                    column(banknavn; Banknavn)
                    {
                    }
                    column(bankbranch; Bankbranch)
                    {
                    }
                    column(bankkontonr; Bankkontonr)
                    {
                    }
                    column(vatNo; VatNo)
                    {
                    }
                    column(giroNo; GiroNo)
                    {
                    }
                    column(DebAdr_1; DebAdr[1])
                    {
                    }
                    column(DebAdr_2; DebAdr[2])
                    {
                    }
                    column(DebAdr_3; DebAdr[3])
                    {
                    }
                    column(DebAdr_4; DebAdr[4])
                    {
                    }
                    column(DebAdr_5; DebAdr[5])
                    {
                    }
                    column(DebAdr_6; DebAdr[6])
                    {
                    }
                    column(EANText; EANText)
                    {
                    }
                    column(Reftext; Reftext)
                    {
                    }
                    column(SelltoCustomerNo_SalesInvoiceHeader; "Sales Invoice Header"."Sell-to Customer No.")
                    {
                    }
                    column(No_SalesInvoiceHeader2; "Sales Invoice Header"."No.")
                    {
                    }
                    column(Reftext2; Reftext2)
                    {
                    }
                    column(SaelgerIndkoeber_Name; SaelgerIndkoeber.Name)
                    {
                    }
                    column(PostingDate_SalesInvoiceHeader; "Sales Invoice Header"."Posting Date")
                    {
                    }
                    column(LevAdresse_1_SideLoekke; LevAdresse[1])
                    {
                    }
                    column(LevAdresse_2_SideLoekke; LevAdresse[2])
                    {
                    }
                    column(LevAdresse_3_SideLoekke; LevAdresse[3])
                    {
                    }
                    column(LevAdresse_4_SideLoekke; LevAdresse[4])
                    {
                    }
                    column(LevAdresse_5_SideLoekke; LevAdresse[5])
                    {
                    }
                    column(txtWoy; TxtWoy)
                    {
                    }
                    column(dow; Dow)
                    {
                    }
                    column(Delivery_date_retaildoc; Retaildoc."Delivery Date")
                    {
                    }
                    column(Delivery_time_retaildoc; Retaildoc."Delivery Time 1")
                    {
                    }
                    column(Delivery_time_2_retaildoc; Retaildoc."Delivery Time 2")
                    {
                    }
                    column(Comment1_1_; Comment1[1])
                    {
                    }
                    column(Comment1_2_; Comment1[2])
                    {
                    }
                    column(DueDate_SalesInvoiceHeader; Format("Sales Invoice Header"."Due Date", 0, 4))
                    {
                    }
                    column(CurrencyCode_SalesInvoiceHeader; "Sales Invoice Header"."Currency Code")
                    {
                    }
                    dataitem("Sales Invoice Line"; "Sales Invoice Line")
                    {
                        DataItemLink = "Document No." = FIELD("No.");
                        DataItemLinkReference = "Sales Invoice Header";
                        DataItemTableView = SORTING("Document No.", "Line No.");
                        column(No_SalesInvoiceLine; "Sales Invoice Line"."No.")
                        {
                        }
                        column(LineNo_SalesInvoiceLine; "Sales Invoice Line"."Line No.")
                        {
                        }
                        column(Description_SalesInvoiceLine; "Sales Invoice Line".Description)
                        {
                        }
                        column(Quantity_SalesInvoiceLine; "Sales Invoice Line".Quantity)
                        {
                        }
                        column(UnitofMeasure_SalesInvoiceLine; "Sales Invoice Line"."Unit of Measure")
                        {
                        }
                        column(UnitPrice_SalesInvoiceLine; "Sales Invoice Line"."Unit Price")
                        {
                        }
                        column(LineDiscount_SalesInvoiceLine; "Sales Invoice Line"."Line Discount %")
                        {
                        }
                        column(Amt_SalesInvoiceLine; 1.25 * (Amount + "Inv. Discount Amount"))
                        {
                        }
                        column(SerialNotCreated; 'Serienr: ' + Format("NPR Serial No. not Created"))
                        {
                        }
                        column(Amount_SalesInvoiceLine; "Sales Invoice Line".Amount)
                        {
                        }
                        column(InclVAT_SalesInvoiceLine; ("Sales Invoice Line"."Amount Including VAT") - ("Sales Invoice Line".Amount))
                        {
                        }
                        column(AmountInclVAT_SalesInvoiceLine; "Sales Invoice Line"."Amount Including VAT")
                        {
                        }
                        column(paidDeposit; PaidDeposit)
                        {
                        }
                        column(AmtPayable_SalesInvoiceLine; "Sales Invoice Line"."Amount Including VAT" - PaidDeposit)
                        {
                        }
                        column(Description_BetalingBetingelse; BetalingBetingelse.Description)
                        {
                        }
                        column(SalesInvLineType; SalesInvLineType)
                        {
                        }
                        column(SerialNonotCreated_SalesInvoiceLine; "Sales Invoice Line"."NPR Serial No. not Created")
                        {
                        }
                        column(DiscountAmt_SalesInvoiceLine; 1.25 * (-"Inv. Discount Amount"))
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            MomsBeloebLinieTemp.Init();
                            MomsBeloebLinieTemp."VAT %" := "VAT %";
                            MomsBeloebLinieTemp."VAT Base" := Amount;
                            MomsBeloebLinieTemp."Amount Including VAT" := "Amount Including VAT";
                            MomsBeloebLinieTemp.InsertLine();
                            case "Sales Invoice Line".Type of
                                "Sales Invoice Line".Type::Item:
                                    begin
                                        SalesInvLineType := 'Item';
                                    end;

                                "Sales Invoice Line".Type::"G/L Account":
                                    begin
                                        SalesInvLineType := 'GLAccount';
                                    end;
                                "Sales Invoice Line".Type::Resource:
                                    begin
                                        SalesInvLineType := 'Resource';
                                    end;
                                "Sales Invoice Line".Type::"Fixed Asset":
                                    begin
                                        SalesInvLineType := 'FixedAsset';
                                    end;

                                "Sales Invoice Line".Type::" ":
                                    begin
                                        SalesInvLineType := '';
                                    end;
                            end;
                        end;

                        trigger OnPreDataItem()
                        begin
                            MomsBeloebLinieTemp.DeleteAll();
                            FlereLinier := FindLast();
                            while FlereLinier and (Description = '') and ("No." = '') and (Quantity = 0) and (Amount = 0) do
                                FlereLinier := Next(-1) <> 0;
                            if not FlereLinier then
                                CurrReport.Break();
                            SetRange("Line No.", 0, "Line No.");
                        end;
                    }
                    dataitem(MomsTaeller; "Integer")
                    {
                        DataItemTableView = SORTING(Number);

                        trigger OnAfterGetRecord()
                        begin
                            MomsBeloebLinieTemp.GetLine(Number);
                        end;

                        trigger OnPreDataItem()
                        begin
                            if MomsBeloebLinieTemp.Count <= 1 then
                                CurrReport.Break();
                            SetRange(Number, 1, MomsBeloebLinieTemp.Count);
                        end;
                    }
                    dataitem("I alt"; "Integer")
                    {
                        DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                    }
                    dataitem("I alt2"; "Integer")
                    {
                        DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));

                        trigger OnPreDataItem()
                        begin
                            if not VisLevAdr then
                                CurrReport.Break();
                        end;
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    if Number > 1 then begin
                        CopyText := CopyTextStr;
                        OutputNo += 1;
                    end;

                    if "Sales Invoice Header"."No. Printed" > 0 then
                        CopyText := CopyTextStr;
                end;

                trigger OnPostDataItem()
                begin
                    if not CurrReport.Preview() then
                        SalgFaktOptaelUdskr.Run("Sales Invoice Header");
                end;

                trigger OnPreDataItem()
                begin
                    LoekkeAntal := Abs(AntalKopier) + Deb."Invoice Copies" + 1;
                    if LoekkeAntal <= 0 then
                        LoekkeAntal := 1;

                    CopyText := '';

                    SetRange(Number, 1, LoekkeAntal);

                    OutputNo := 1;

                end;
            }

            trigger OnAfterGetRecord()
            var
                Debpost: Record "Cust. Ledger Entry";
                POSStore: Record "NPR POS Store";
                POSUnit: Record "NPR POS Unit";
                Register: Record "NPR Register";
                Bestilling: Record "NPR Retail Document Header";
                Comments: Record "Sales Comment Line";
                POSFrontEnd: Codeunit "NPR POS Front End Management";
                POSSession: Codeunit "NPR POS Session";
                POSSetup: Codeunit "NPR POS Setup";
                Retailformcode: Codeunit "NPR Retail Form Code";
                RestBeloeb: Decimal;
            begin
                if "Order No." = '' then
                    OrdreNrTekst := ''
                else
                    OrdreNrTekst := FieldName("Order No.");
                if "Salesperson Code" = '' then begin
                    SaelgerIndkoeber.Init;
                    SaelgerTekst := '';
                end else begin
                    SaelgerIndkoeber.Get("Salesperson Code");
                    SaelgerTekst := 'Saelger';
                end;
                if "Your Reference" = '' then
                    ReferenceTekst := ''
                else
                    ReferenceTekst := FieldName("Your Reference");
                if "VAT Registration No." = '' then
                    MomsNrTekst := ''
                else
                    MomsNrTekst := FieldName("VAT Registration No.");
                if "Currency Code" = '' then begin
                    FinansOpsaet.TestField("LCY Code");
                    TotalTekst := StrSubstNo('I alt %1', FinansOpsaet."LCY Code");
                    TotaltInklMomsTekst := StrSubstNo('I alt %1 inkl. moms', FinansOpsaet."LCY Code");
                end else begin
                    TotalTekst := StrSubstNo('I alt %1', "Currency Code");
                    TotaltInklMomsTekst := StrSubstNo('I alt %1 inkl. moms', "Currency Code");
                end;
                FormatAdr.SalesInvBillTo(DebAdr, "Sales Invoice Header");
                if "Sales Invoice Header"."Bill-to Country/Region Code" <> '' then
                    Lande.Get("Sales Invoice Header"."Bill-to Country/Region Code");
                Deb.Get("Bill-to Customer No.");
                DebAdr[1] := "Bill-to Name";
                DebAdr[2] := Deb.Contact;
                DebAdr[3] := "Bill-to Name 2";
                DebAdr[4] := "Bill-to Address";
                DebAdr[5] := "Bill-to Address 2";
                DebAdr[6] := "Sales Invoice Header"."Bill-to Post Code" + ' ' + "Bill-to City";
                DebAdr[7] := Lande.Name;
                CompressArray(DebAdr);

                DK_Localization.T18_GetFieldValue(Deb, 'EAN No.', DK_VariantVar);
                Evaluate(EAN_No, DK_VariantVar);
                if (EAN_No <> '') then
                    EANText := StrSubstNo(EANTextStr, EAN_No);

                if "Sales Invoice Header"."External Document No." <> '' then
                    Reftext := StrSubstNo(Reftextstr, "Sales Invoice Header"."External Document No.");

                if Deb.Contact <> "Sales Invoice Header"."Your Reference" then
                    Reftext2 := "Sales Invoice Header"."Your Reference";

                if "Payment Terms Code" = '' then
                    BetalingBetingelse.Init
                else
                    BetalingBetingelse.Get("Payment Terms Code");
                if "Shipment Method Code" = '' then
                    LevForm.Init
                else
                    LevForm.Get("Shipment Method Code");

                VisLevAdr := FormatAddr.SalesInvShipTo(LevAdresse, DebAdr, "Sales Invoice Header");

                if (FirmaOplysninger."Giro No." <> '') then
                    GiroNrTxt := 'Gironr.'
                else
                    GiroNrTxt := '';

                if (FirmaOplysninger."VAT Registration No." <> '') then
                    FirmaMomsNrTxT := 'Momsnr.'
                else
                    FirmaMomsNrTxT := '';

                Kunde.Get("Sell-to Customer No.");

                // Check Acontobeloeb
                AcontoBeloeb := 0;
                if ("Sales Invoice Header"."Applies-to Doc. Type" = "Sales Invoice Header"."Applies-to Doc. Type"::Payment) and
                   ("Sales Invoice Header"."Applies-to Doc. No." <> '')
                  then begin
                    Debpost.SetRange("Customer No.", "Sales Invoice Header"."Bill-to Customer No.");
                    Debpost.SetRange("Document Type", Debpost."Document Type"::Invoice);
                    Debpost.SetRange("Document No.", "Sales Invoice Header"."No.");
                    if Debpost.FindFirst then begin
                        if Debpost."Remaining Amount" = 0 then //{ Hele faktura er aconto }
                            AcontoBeloeb := Debpost.Amount;
                        if (Debpost.Amount > Debpost."Remaining Amount") and (Debpost."Remaining Amount" > 0) then
                            AcontoBeloeb := Debpost.Amount - Debpost."Remaining Amount";
                    end;
                end;

                NPRopsaetning.Get();
                case NPRopsaetning."Base for FIK-71" of
                    NPRopsaetning."Base for FIK-71"::Invoice:
                        "Betalings-ID" := PadStr('', 13 - StrLen("No."), '0') + "No." + '0';
                    NPRopsaetning."Base for FIK-71"::Customer:
                        begin
                            "Betalings-ID" := PadStr('', 13 - StrLen("Bill-to Customer No."), '0') + "Bill-to Customer No." + '0';
                        end else
                                "Betalings-ID" := PadStr('', 13 - StrLen("No."), '0') + "No." + '0';
                end;

                "Betalings-ID" := "Betalings-ID" + Modulus10("Betalings-ID");
                if KortArt = '73' then
                    "Betalings-ID" := '';

                CalcFields(Comment);
                if Comment then begin
                    Comments.SetRange("Document Type", Comments."Document Type"::"Posted Invoice");
                    Comments.SetRange("No.", "No.");
                    if Comments.FindFirst then begin
                        Comment1[1] := Comments.Comment;
                        if Comments.Next <> 0 then
                            Comment1[2] := Comments.Comment;
                    end;
                end;

                FirmaOplysninger.Get();

                if RespCenter.Get("Responsibility Center") then begin
                    FormatAddr.RespCenter(Companyaddr, RespCenter);
                    FirmaOplysninger."Phone No." := RespCenter."Phone No.";
                    FirmaOplysninger."Fax No." := RespCenter."Fax No.";
                end else
                    FormatAddr.Company(Companyaddr, FirmaOplysninger);

                if Register.Get(Retailformcode.FetchRegisterNumber) then begin
                    Clear(Companyaddr);
                    clear(POSStore);
                    if POSSession.IsActiveSession(POSFrontEnd) then begin
                        POSFrontEnd.GetSession(POSSession);
                        POSSession.GetSetup(POSSetup);
                        POSSetup.GetPOSStore(POSStore);
                    end else begin
                        if POSUnit.get(Register."Register No.") then
                            POSStore.get(POSUnit."POS Store Code");
                    end;
                    Companyaddr[1] := POSStore.Name;
                    Companyaddr[2] := POSStore."Name 2";
                    Companyaddr[3] := POSStore.Address;
                    Companyaddr[4] := POSStore."Post Code" + ' ' + POSStore.City;
                    Companyaddr[5] := POSStore."Phone No.";
                    Companyaddr[6] := POSStore."Fax No.";
                    CompressArray(Companyaddr);
                end;

                Banknavn := FirmaOplysninger."Bank Name";
                Bankbranch := FirmaOplysninger."Bank Branch No.";
                Bankkontonr := FirmaOplysninger."Bank Account No.";
                VatNo := FirmaOplysninger."VAT Registration No.";
                GiroNo := FirmaOplysninger."Giro No.";

                PaidDeposit := 0;
                if "NPR Sales Ticket No." <> '' then begin
                    Auditroll.SetRange("Sales Ticket No.", "NPR Sales Ticket No.");

                    if Auditroll.FindFirst then
                        repeat
                            if Auditroll."Retail Document No." <> '' then begin
                                Retaildoc.SetRange("Document Type", Auditroll."Retail Document Type");
                                Retaildoc.SetRange("No.", Auditroll."Retail Document No.");
                                if Retaildoc.FindFirst then begin
                                    if Retaildoc."Delivery Date" <> 0D then begin
                                        case Date2DWY(Retaildoc."Delivery Date", 1) of
                                            1:
                                                Dow := MonTXT;
                                            2:
                                                Dow := TueTXT;
                                            3:
                                                Dow := WedTXT;
                                            4:
                                                Dow := ThuTXT;
                                            5:
                                                Dow := FriTXT;
                                            6:
                                                Dow := SatTXT;
                                            7:
                                                Dow := SunTXT;
                                        end;
                                        TxtWoy := T001 + ' ' + Format(Date2DWY(Retaildoc."Delivery Date", 2));
                                    end;
                                end;
                            end;
                        until Auditroll.Next() = 0;
                end;

                Debpost.SetRange("Document Type", Debpost."Document Type"::Invoice);
                Debpost.SetRange("Document No.", "No.");
                if Debpost.FindFirst() then begin
                    Debpost.CalcFields("Remaining Amount");
                    RestBeloeb := Debpost."Remaining Amount";
                end;

                if RestBeloeb = 0 then begin
                    Debpost.CalcFields("Original Amount");
                    PaidDeposit := Debpost."Original Amount";
                end else begin
                    Bestilling.SetRange("Document Type", Bestilling."Document Type"::"Retail Order");
                    Bestilling.SetRange("No.", "External Document No.");

                    if Bestilling.FindFirst() then
                        PaidDeposit := Bestilling.Deposit;
                end;

                if "Sales Invoice Header"."Location Code" = '' then begin
                    Clear(FirmaAdr);
                    FirmaAdr[1] := FirmaOplysninger.Name;
                    FirmaAdr[2] := FirmaOplysninger."Name 2";
                    FirmaAdr[3] := FirmaOplysninger.Address;
                    FirmaAdr[4] := FirmaOplysninger."Address 2";
                    FirmaAdr[5] := FirmaOplysninger."Post Code" + ' ' + FirmaOplysninger.City;
                    CompressArray(FirmaAdr);

                    FirmaTlf := FirmaOplysninger."Phone No.";
                    FirmaFax := FirmaOplysninger."Fax No.";
                    FirmaMomsnr := FirmaOplysninger."VAT Registration No.";
                    FirmaGironr := FirmaOplysninger."Giro No.";
                end else begin
                    if Lokation.Get("Sales Invoice Header"."Location Code") then begin
                        FirmaTlf := Lokation."Phone No.";
                        FirmaFax := Lokation."Fax No.";
                        Clear(FirmaAdr);
                        FirmaAdr[1] := Lokation.Name;
                        FirmaAdr[2] := Lokation."Name 2";
                        FirmaAdr[3] := Lokation.Address;
                        FirmaAdr[4] := Lokation."Address 2";
                        FirmaAdr[5] := Lokation."Post Code" + ' ' + Lokation.City;
                        CompressArray(FirmaAdr);
                    end;
                end;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(AntalKopier; AntalKopier)
                {
                    Caption = 'Copy Qty.';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Copy Qty. field';
                }
                field(Sprog; Sprog)
                {
                    Caption = 'Language';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Language field';
                }
            }
        }

    }

    labels
    {
        Report_Caption = 'Sales Invoice A4 (Retail)';
        Customer_No_Caption = 'Customer No.';
        Invoice_No_Caption = 'Invoice No.';
        Pick_Up_Caption = 'Picked up By:';
        Salesperson_Caption = 'Salesperson';
        Date_Caption = 'Date';
        Page_Caption = 'Page';
        Delivery_Caption = 'Delivery';
        Comments_Caption = 'Comments';
        Item_No_Caption = 'Item No.';
        Description_Caption = 'Description';
        Quantity_Caption = 'Quantity';
        Unit_Price_Caption = 'Unit Price';
        Amount_Caption = 'Amount';
        Continued_Caption = 'Continued';
        Total_Disc_Amt_Caption = 'Total Disc. Amount';
        Total_Caption = 'Total';
        VAT_Caption = 'VAT Amount';
        Incl_VAT_Caption = 'Inc. VAT ';
        Account_Caption = 'Account';
        Payable_Caption = 'Payable';
        Payment_Caption = 'Payment:';
        LastDayPayment_Caption = 'Last Day of Payment';
        Intact_Caption = 'Having received intact items';
        Remaining_Amt_Caption = 'Having received above remaining amount';
    }

    trigger OnInitReport()
    var
        Opsaetning: Record "NPR Retail Setup";
    begin
        FinansOpsaet.Get();
        AntalKopier := 0;
        FirmaOplysninger.Get;
        FirmaOplysninger.CalcFields(Picture);
        Sideskift := 0;
        Opsaetning.Get;
        FIKnr := Opsaetning."FIK No.";
        EANText := '';
    end;

    trigger OnPreReport()
    begin
        if Sprog = Sprog::Engelsk then
            CurrReport.Language := 2057
        else
            CurrReport.Language := 1030;
    end;

    var
        FirmaOplysninger: Record "Company Information";
        Lande: Record "Country/Region";
        Deb: Record Customer;
        Kunde: Record Customer;
        FinansOpsaet: Record "General Ledger Setup";
        Lokation: Record Location;
        Auditroll: Record "NPR Audit Roll";
        Retaildoc: Record "NPR Retail Document Header";
        NPRopsaetning: Record "NPR Retail Setup";
        BetalingBetingelse: Record "Payment Terms";
        RespCenter: Record "Responsibility Center";
        SaelgerIndkoeber: Record "Salesperson/Purchaser";
        LevForm: Record "Shipment Method";
        MomsBeloebLinieTemp: Record "VAT Amount Line" temporary;
        FormatAddr: Codeunit "Format Address";
        FormatAdr: Codeunit "Format Address";
        DK_Localization: Codeunit "NPR Doc. Localization Proxy";
        SalgFaktOptaelUdskr: Codeunit "Sales Inv.-Printed";
        FlereLinier: Boolean;
        VisLevAdr: Boolean;
        KortArt: Code[4];
        FIKnr: Code[10];
        EAN_No: Code[13];
        "Betalings-ID": Code[16];
        AcontoBeloeb: Decimal;
        PaidDeposit: Decimal;
        AntalKopier: Integer;
        LoekkeAntal: Integer;
        o: Integer;
        OutputNo: Integer;
        Sideskift: Integer;
        CopyTextStr: Label 'COPY';
        EANTextStr: Label 'EAN No.: %1';
        FriTXT: Label 'Friday';
        TitleText: Label 'Invoice';
        MonTXT: Label 'Monday';
        Reftextstr: Label 'Ref no: %1';
        SatTXT: Label 'Saturday';
        SunTXT: Label 'Saturday';
        ThuTXT: Label 'Thursday';
        TueTXT: Label 'Tuesday';
        WedTXT: Label 'Wednesday';
        T001: Label 'Week';
        Sprog: Option Dansk,Engelsk;
        Dow: Text[10];
        FirmaFax: Text[20];
        FirmaGironr: Text[20];
        FirmaMomsnr: Text[20];
        FirmaTlf: Text[20];
        Bankbranch: Text[30];
        Bankkontonr: Text[30];
        CopyText: Text[30];
        EANText: Text[30];
        FirmaMomsNrTxT: Text[30];
        GiroNo: Text[30];
        GiroNrTxt: Text[30];
        MomsNrTekst: Text[30];
        OrdreNrTekst: Text[30];
        ReferenceTekst: Text[30];
        Reftext: Text[30];
        Reftext2: Text[30];
        SaelgerTekst: Text[30];
        SalesInvLineType: Text[30];
        TxtWoy: Text[30];
        VatNo: Text[30];
        Banknavn: Text[50];
        Comment1: array[2] of Text[50];
        Companyaddr: array[8] of Text[50];
        DebAdr: array[8] of Text[50];
        FirmaAdr: array[8] of Text[50];
        LevAdresse: array[8] of Text[50];
        TotalTekst: Text[50];
        TotaltInklMomsTekst: Text[50];
        DK_VariantVar: Variant;

    procedure Modulus10(ID: Code[19]): Code[10]
    var
        SumStr: Code[19];
        Summer: Integer;
        Taeller: Integer;
        Vaegttal: Integer;
    begin
        Vaegttal := 2;
        SumStr := '';
        for Taeller := StrLen(ID) downto 1 do begin
            Evaluate(Summer, CopyStr(ID, Taeller, 1));
            Summer := Summer * Vaegttal;
            SumStr := SumStr + Format(Summer);
            if Vaegttal = 1 then
                Vaegttal := 2
            else
                Vaegttal := 1;
        end;
        Summer := 0;
        for Taeller := 1 to StrLen(SumStr) do begin
            Evaluate(Vaegttal, CopyStr(SumStr, Taeller, 1));
            Summer := Summer + Vaegttal;
        end;
        Summer := 10 - (Summer mod 10);
        if Summer = 10 then
            exit('0')
        else
            exit(Format(Summer));
    end;
}

