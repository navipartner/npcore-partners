xmlport 6184850 "FR Audit Archive"
{
    // NPR5.48/MMV /20181025 CASE 318028 Created object

    Caption = 'FR Audit Archive';
    Direction = Export;
    Encoding = UTF8;
    FormatEvaluate = Xml;

    schema
    {
        tableelement(pcheckpoint;"POS Workshift Checkpoint")
        {
            XmlName = 'GrandPeriod';
            fieldelement(SystemEntryKey;PCheckpoint."Entry No.")
            {
            }
            textelement(pexternalid)
            {
                XmlName = 'ID';
            }
            fieldelement(CreatedAt;PCheckpoint."Created At")
            {
            }
            textelement(pgrandtotal)
            {
                XmlName = 'GrandTotal';
            }
            textelement(pperpetualgrandtotal)
            {
                XmlName = 'PerpetualGrandTotal';
            }
            textelement(psignature)
            {
                XmlName = 'Signature';
            }
            textelement(grandperiodtaxlines)
            {
                MaxOccurs = Once;
                XmlName = 'TaxLines';
                tableelement(grandperiodtaxline;"POS Workshift Tax Checkpoint")
                {
                    LinkFields = "Workshift Checkpoint Entry No."=FIELD("Entry No.");
                    LinkTable = PCheckpoint;
                    MinOccurs = Zero;
                    XmlName = 'TaxLine';
                    fieldelement(TaxIdentifier;GrandPeriodTaxLine."VAT Identifier")
                    {
                    }
                    fieldelement(TaxRate;GrandPeriodTaxLine."Tax %")
                    {
                    }
                    fieldelement(TaxBaseAmount;GrandPeriodTaxLine."Tax Base Amount")
                    {
                    }
                    fieldelement(TaxAmount;GrandPeriodTaxLine."Tax Amount")
                    {
                    }
                }
            }
            tableelement(zcheckpoint;"POS Workshift Checkpoint")
            {
                XmlName = 'Period';
                fieldelement(SystemEntryKey;ZCheckpoint."Entry No.")
                {
                }
                textelement(zexternalid)
                {
                    XmlName = 'ID';
                }
                fieldelement(CreatedAt;ZCheckpoint."Created At")
                {
                }
                textelement(zgrandtotal)
                {
                    XmlName = 'GrandTotal';
                }
                textelement(zperpetualgrandtotal)
                {
                    XmlName = 'PerpetualGrandTotal';
                }
                textelement(zsignature)
                {
                    XmlName = 'Signature';
                }
                textelement(periodtaxlines)
                {
                    XmlName = 'TaxLines';
                    tableelement(periodtaxline;"POS Workshift Tax Checkpoint")
                    {
                        LinkFields = "Workshift Checkpoint Entry No."=FIELD("Entry No.");
                        LinkTable = ZCheckpoint;
                        MinOccurs = Zero;
                        XmlName = 'TaxLine';
                        fieldelement(TaxIdentifier;PeriodTaxLine."VAT Identifier")
                        {
                        }
                        fieldelement(TaxRate;PeriodTaxLine."Tax %")
                        {
                        }
                        fieldelement(TaxBaseAmount;PeriodTaxLine."Tax Base Amount")
                        {
                        }
                        fieldelement(TaxAmount;PeriodTaxLine."Tax Amount")
                        {
                        }
                    }
                }
                tableelement("POS Entry";"POS Entry")
                {
                    MinOccurs = Zero;
                    XmlName = 'Ticket';
                    fieldelement(SystemEntryKey;"POS Entry"."Entry No.")
                    {
                    }
                    fieldelement(DocumentNumber;"POS Entry"."Fiscal No.")
                    {
                    }
                    fieldelement(NoOfPrints;"POS Entry"."No. of Print Output Entries")
                    {
                    }
                    fieldelement(SalespersonCode;"POS Entry"."Salesperson Code")
                    {
                    }
                    fieldelement(POSCode;"POS Entry"."POS Unit No.")
                    {
                    }
                    fieldelement(Date;"POS Entry"."Entry Date")
                    {
                    }
                    fieldelement(Time;"POS Entry"."Ending Time")
                    {
                    }
                    fieldelement(OperationType;"POS Entry"."Entry Type")
                    {
                    }
                    textelement(documenttype)
                    {
                        XmlName = 'DocumentType';
                    }
                    fieldelement(NoOfSaleLines;"POS Entry"."No. of Sales Lines")
                    {
                    }
                    textelement(tsignature)
                    {
                        XmlName = 'Signature';
                    }
                    tableelement("FR POS Audit Log Aux. Info";"FR POS Audit Log Aux. Info")
                    {
                        LinkFields = "POS Entry No."=FIELD("Entry No.");
                        LinkTable = "POS Entry";
                        MaxOccurs = Once;
                        XmlName = 'RelatedInfo';
                        fieldelement(SoftwareVersion;"FR POS Audit Log Aux. Info"."NPR Version")
                        {
                        }
                        fieldelement(StoreName;"FR POS Audit Log Aux. Info"."Store Name")
                        {
                        }
                        fieldelement(StoreName2;"FR POS Audit Log Aux. Info"."Store Name 2")
                        {
                        }
                        fieldelement(StoreAddress;"FR POS Audit Log Aux. Info"."Store Address")
                        {
                        }
                        fieldelement(StoreAddress2;"FR POS Audit Log Aux. Info"."Store Address 2")
                        {
                        }
                        fieldelement(StorePostCode;"FR POS Audit Log Aux. Info"."Store Post Code")
                        {
                        }
                        fieldelement(StoreCity;"FR POS Audit Log Aux. Info"."Store City")
                        {
                        }
                        fieldelement(Siret;"FR POS Audit Log Aux. Info"."Store Siret")
                        {
                        }
                        fieldelement(APE;"FR POS Audit Log Aux. Info".APE)
                        {
                        }
                        fieldelement(IntraCommVATIdentifier;"FR POS Audit Log Aux. Info"."Intra-comm. VAT ID")
                        {
                        }
                        fieldelement(SalespersonName;"FR POS Audit Log Aux. Info"."Salesperson Name")
                        {
                        }
                    }
                    textelement(SalesLines)
                    {
                        tableelement("POS Sales Line";"POS Sales Line")
                        {
                            LinkFields = "POS Entry No."=FIELD("Entry No.");
                            LinkTable = "POS Entry";
                            MinOccurs = Zero;
                            XmlName = 'SalesLine';
                            fieldelement(LineNo;"POS Sales Line"."Line No.")
                            {
                            }
                            fieldelement(ProductCode;"POS Sales Line"."No.")
                            {
                            }
                            fieldelement(ProductLabel;"POS Sales Line".Description)
                            {
                            }
                            fieldelement(Quantity;"POS Sales Line".Quantity)
                            {
                            }
                            fieldelement(TaxIdentifier;"POS Sales Line"."VAT Identifier")
                            {
                            }
                            fieldelement(TaxRate;"POS Sales Line"."VAT %")
                            {
                            }
                            fieldelement(UnitPriceInclTax;"POS Sales Line"."Unit Price")
                            {
                            }
                            fieldelement(DiscountCode;"POS Sales Line"."Discount Code")
                            {
                            }
                            fieldelement(DiscountPercentage;"POS Sales Line"."Line Discount %")
                            {
                            }
                            fieldelement(DiscountAmount;"POS Sales Line"."Line Discount Amount Incl. VAT")
                            {
                            }
                            fieldelement(TotalExclTax;"POS Sales Line"."Amount Excl. VAT")
                            {
                            }
                            fieldelement(TotalInclTax;"POS Sales Line"."Amount Incl. VAT")
                            {
                            }
                            fieldelement(BaseQuantity;"POS Sales Line"."Quantity (Base)")
                            {
                            }
                            fieldelement(UnitOfMeasureCode;"POS Sales Line"."Unit of Measure Code")
                            {
                            }
                        }
                    }
                    textelement(TaxLines)
                    {
                        tableelement("POS Tax Amount Line";"POS Tax Amount Line")
                        {
                            LinkFields = "POS Entry No."=FIELD("Entry No.");
                            LinkTable = "POS Entry";
                            MinOccurs = Zero;
                            XmlName = 'TaxLine';
                            fieldelement(TaxIdentifier;"POS Tax Amount Line"."VAT Identifier")
                            {
                            }
                            fieldelement(TaxBaseAmount;"POS Tax Amount Line"."Tax Base Amount")
                            {
                            }
                            fieldelement(TaxRate;"POS Tax Amount Line"."Tax %")
                            {
                            }
                            fieldelement(TaxAmount;"POS Tax Amount Line"."Tax Amount")
                            {
                            }
                            fieldelement(AmountInclTax;"POS Tax Amount Line"."Amount Including Tax")
                            {
                            }
                        }
                    }
                    tableelement(ticketgrandtotal;"POS Audit Log")
                    {
                        LinkFields = "Acted on POS Entry No."=FIELD("Entry No.");
                        LinkTable = "POS Entry";
                        MaxOccurs = Once;
                        XmlName = 'TicketTotals';
                        SourceTableView = WHERE("External Type"=CONST('GRANDTOTAL'));
                        fieldelement(TotalInclTax;"POS Entry"."Total Amount Incl. Tax")
                        {
                        }
                        fieldelement(TotalExclTax;"POS Entry"."Total Amount")
                        {
                        }
                        fieldelement(PerpetualGrandTotal;TicketGrandTotal."Additional Information")
                        {
                        }
                        textelement(ttsignature)
                        {
                            XmlName = 'GrandTotalSignature';
                        }

                        trigger OnAfterGetRecord()
                        var
                            POSAuditLog: Record "POS Audit Log";
                        begin
                            POSAuditLog.SetRange("Record ID", "POS Entry".RecordId);
                            POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::GRANDTOTAL);
                            TTSignature := GetAuditSignature(POSAuditLog);
                        end;
                    }
                    textelement(PaymentLines)
                    {
                        tableelement("POS Payment Line";"POS Payment Line")
                        {
                            LinkFields = "POS Entry No."=FIELD("Entry No.");
                            LinkTable = "POS Entry";
                            MinOccurs = Zero;
                            XmlName = 'PaymentLine';
                            fieldelement(Code;"POS Payment Line"."POS Payment Method Code")
                            {
                            }
                            textelement(paymentlinetype)
                            {
                                XmlName = 'Type';
                            }
                            fieldelement(Description;"POS Payment Line".Description)
                            {
                            }
                            fieldelement(Amount;"POS Payment Line"."Amount (LCY)")
                            {
                            }
                            fieldelement(Currency;"POS Payment Line"."Currency Code")
                            {
                            }
                            fieldelement(CurrencyAmount;"POS Payment Line"."Amount (Sales Currency)")
                            {
                            }
                            textelement(paymentlineexchrate)
                            {
                                XmlName = 'ExchangeRate';
                            }

                            trigger OnAfterGetRecord()
                            var
                                PaymentTypePOS: Record "Payment Type POS";
                            begin
                                if not PaymentTypePOS.Get("POS Payment Line"."POS Payment Method Code","POS Payment Line"."POS Unit No.") then
                                  PaymentTypePOS.Get("POS Payment Line"."POS Payment Method Code", '');

                                PaymentLineType := Format(PaymentTypePOS."Processing Type");
                                PaymentLineExchRate := Format(Round("POS Payment Line"."Amount (LCY)" / "POS Payment Line"."Amount (Sales Currency)", 0.00001, '='));
                            end;
                        }
                    }
                    textelement(PrintDuplicates)
                    {
                        tableelement("POS Entry Output Log";"POS Entry Output Log")
                        {
                            LinkFields = "POS Entry No."=FIELD("Entry No.");
                            LinkTable = "POS Entry";
                            MinOccurs = Zero;
                            XmlName = 'PrintDuplicate';
                            SourceTableView = WHERE("Output Method"=CONST(Print),"Output Type"=FILTER(SalesReceipt|LargeSalesReceipt));
                            textelement(outputexternalid)
                            {
                                XmlName = 'ID';
                            }
                            textelement(outputreprintnumber)
                            {
                                XmlName = 'ReprintNumber';
                            }
                            fieldelement(SalespersonCode;"POS Entry Output Log"."Salesperson Code")
                            {
                            }
                            fieldelement(UserCode;"POS Entry Output Log"."User ID")
                            {
                            }
                            fieldelement(Timestamp;"POS Entry Output Log"."Output Timestamp")
                            {
                            }
                            textelement(outputsignature)
                            {
                                XmlName = 'Signature';
                            }

                            trigger OnAfterGetRecord()
                            var
                                POSAuditLog: Record "POS Audit Log";
                            begin
                                POSAuditLog.SetRange("Record ID", "POS Entry Output Log".RecordId);
                                POSAuditLog.SetFilter("Action Type", '=%1|=%2', POSAuditLog."Action Type"::RECEIPT_COPY, POSAuditLog."Action Type"::RECEIPT_PRINT);
                                POSAuditLog.FindFirst;

                                if POSAuditLog."Action Type" = POSAuditLog."Action Type"::RECEIPT_PRINT then
                                  currXMLport.Skip;

                                OutputExternalID := POSAuditLog."External ID";
                                OutputReprintNumber := POSAuditLog."Additional Information"; //Contains reprint no.
                                OutputSignature := GetAuditSignature(POSAuditLog);
                            end;
                        }
                    }
                    textelement(AssociatedDocuments)
                    {
                        tableelement(issuedcreditvoucher;"Credit Voucher")
                        {
                            LinkFields = "Issuing POS Entry No"=FIELD("Entry No.");
                            LinkTable = "POS Entry";
                            MinOccurs = Zero;
                            XmlName = 'IssuedCreditVoucher';
                            fieldelement(VoucherNo;IssuedCreditVoucher."No.")
                            {
                            }
                            fieldelement(Amount;IssuedCreditVoucher.Amount)
                            {
                            }
                        }
                        tableelement(appliedcreditvoucher;"Credit Voucher")
                        {
                            LinkFields = "Cashed POS Entry No."=FIELD("Entry No.");
                            LinkTable = "POS Entry";
                            MinOccurs = Zero;
                            XmlName = 'AppliedCreditVoucher';
                            fieldelement(VoucherNo;AppliedCreditVoucher."No.")
                            {
                            }
                            fieldelement(Amount;AppliedCreditVoucher.Amount)
                            {
                            }
                        }
                        tableelement(issuedgiftvoucher;"Gift Voucher")
                        {
                            LinkFields = "Issuing POS Entry No"=FIELD("Entry No.");
                            LinkTable = "POS Entry";
                            MinOccurs = Zero;
                            XmlName = 'IssuedGiftVoucher';
                            fieldelement(VoucherNo;IssuedGiftVoucher."No.")
                            {
                            }
                            fieldelement(Amount;IssuedGiftVoucher.Amount)
                            {
                            }
                        }
                        tableelement(appliedgiftvoucher;"Gift Voucher")
                        {
                            LinkFields = "Cashed POS Entry No."=FIELD("Entry No.");
                            LinkTable = "POS Entry";
                            MinOccurs = Zero;
                            XmlName = 'AppliedGiftVoucher';
                            fieldelement(VoucherNo;AppliedGiftVoucher."No.")
                            {
                            }
                            fieldelement(Amount;AppliedGiftVoucher.Amount)
                            {
                            }
                        }
                        tableelement(issuedgenericvoucher;"NpRv Voucher Entry")
                        {
                            LinkFields = "Register No."=FIELD("POS Unit No."),"Document No."=FIELD("Document No.");
                            LinkTable = "POS Entry";
                            MinOccurs = Zero;
                            XmlName = 'IssuedGenericVoucher';
                            SourceTableView = WHERE("Entry Type"=CONST("Issue Voucher"));
                            fieldelement(VoucherNo;IssuedGenericVoucher."Voucher No.")
                            {
                            }
                            fieldelement(VoucherType;IssuedGenericVoucher."Voucher Type")
                            {
                            }
                            fieldelement(Amount;IssuedGenericVoucher.Amount)
                            {
                            }
                        }
                        tableelement(appliedgenericvoucher;"NpRv Voucher Entry")
                        {
                            LinkFields = "Register No."=FIELD("POS Unit No."),"Document No."=FIELD("Document No.");
                            LinkTable = "POS Entry";
                            MinOccurs = Zero;
                            XmlName = 'AppliedGenericVoucher';
                            SourceTableView = WHERE("Entry Type"=CONST(Payment));
                            fieldelement(VoucherNo;AppliedGenericVoucher."Voucher No.")
                            {
                            }
                            fieldelement(VoucherType;AppliedGenericVoucher."Voucher Type")
                            {
                            }
                            fieldelement(AppliedAmount;AppliedGenericVoucher.Amount)
                            {
                            }
                            fieldelement(RemainingAmount;AppliedGenericVoucher."Remaining Amount")
                            {
                            }
                        }
                        tableelement(issuedcoupon;"NpDc Coupon Entry")
                        {
                            LinkFields = "Register No."=FIELD("POS Unit No."),"Sales Ticket No."=FIELD("Document No.");
                            LinkTable = "POS Entry";
                            MinOccurs = Zero;
                            XmlName = 'IssuedCoupon';
                            SourceTableView = WHERE("Entry Type"=CONST("Issue Coupon"));
                            fieldelement(CouponNo;IssuedCoupon."Coupon No.")
                            {
                            }
                            fieldelement(CouponType;IssuedCoupon."Coupon Type")
                            {
                            }
                            fieldelement(Quantity;IssuedCoupon.Quantity)
                            {
                            }
                            fieldelement(AmountPerQuantity;IssuedCoupon."Amount per Qty.")
                            {
                            }
                        }
                        tableelement(appliedcoupon;"NpDc Coupon Entry")
                        {
                            LinkFields = "Register No."=FIELD("POS Unit No."),"Sales Ticket No."=FIELD("Document No.");
                            LinkTable = "POS Entry";
                            MinOccurs = Zero;
                            XmlName = 'AppliedCoupon';
                            SourceTableView = WHERE("Entry Type"=CONST("Discount Application"));
                            fieldelement(CouponNo;AppliedCoupon."Coupon No.")
                            {
                            }
                            fieldelement(CouponType;AppliedCoupon."Coupon Type")
                            {
                            }
                            fieldelement(AppliedQuantity;AppliedCoupon.Quantity)
                            {
                            }
                            fieldelement(RemainingQuantity;AppliedCoupon."Remaining Quantity")
                            {
                            }
                            fieldelement(AmountPerQuantity;AppliedCoupon."Amount per Qty.")
                            {
                            }
                        }
                    }

                    trigger OnAfterGetRecord()
                    var
                        POSAuditLog: Record "POS Audit Log";
                        InStream: InStream;
                    begin
                        if IsCancelledSale("POS Entry") then
                          currXMLport.Skip;

                        POSAuditLog.SetRange("Record ID", "POS Entry".RecordId);
                        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::DIRECT_SALE_END);
                        POSAuditLog.FindFirst;
                        DocumentType := POSAuditLog."External Type";
                        TSignature := GetAuditSignature(POSAuditLog);
                    end;

                    trigger OnPreXmlItem()
                    begin
                        "POS Entry".SetRange("POS Entry"."Entry No.", FromPOSEntry, ToPOSEntry);
                        "POS Entry".SetRange("POS Entry"."POS Unit No.", UnitNo);
                        "POS Entry".SetRange("POS Entry"."Entry Type", "POS Entry"."Entry Type"::"Direct Sale");
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    LookaheadZReport: Record "POS Workshift Checkpoint";
                    POSAuditLog: Record "POS Audit Log";
                    InStream: InStream;
                begin
                    if not FirstZReport then
                      FromPOSEntry := ZCheckpoint."POS Entry No.";

                    LookaheadZReport.SetRange("POS Unit No.", UnitNo);
                    LookaheadZReport.SetFilter(Type, '=%1|=%2', LookaheadZReport.Type::PREPORT, LookaheadZReport.Type::ZREPORT);
                    LookaheadZReport.SetFilter("Entry No.", '>%1', ZCheckpoint."Entry No.");
                    LookaheadZReport.SetRange(Open, false);
                    LookaheadZReport.FindFirst;
                    ToPOSEntry := LookaheadZReport."POS Entry No.";

                    POSAuditLog.SetRange("Record ID", ZCheckpoint.RecordId);
                    POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::GRANDTOTAL);
                    POSAuditLog.FindFirst;
                    ZExternalID := POSAuditLog."External ID";
                    ZPerpetualGrandTotal := POSAuditLog."Additional Information"; //Contains perpetual for daily period.
                    ZSignature := GetAuditSignature(POSAuditLog);
                    ZGrandTotal := Format(ZCheckpoint."Direct Turnover (LCY)" - ZCheckpoint."Rounding (LCY)",0,'<Precision,2:2><Standard Format,9>');

                    FirstZReport := false;
                end;

                trigger OnPreXmlItem()
                begin
                    ZCheckpoint.SetRange(Type, ZCheckpoint.Type::ZREPORT);
                    ZCheckpoint.SetRange("POS Unit No.", UnitNo);
                    ZCheckpoint.SetRange("Entry No.", FromZReportEntry, ToZReportEntry);
                    ZCheckpoint.SetRange(Open, false);
                end;
            }
            textelement(JET)
            {
                tableelement(jetentry;"POS Audit Log")
                {
                    XmlName = 'JETEntry';
                    fieldelement(ID;JETEntry."External ID")
                    {
                    }
                    fieldelement(Code;JETEntry."External Code")
                    {
                    }
                    fieldelement(Description;JETEntry."External Description")
                    {
                    }
                    fieldelement(Salesperson;JETEntry."Active Salesperson Code")
                    {
                    }
                    fieldelement(Timestamp;JETEntry."Log Timestamp")
                    {
                    }
                    fieldelement(AdditionalInfo;JETEntry."Additional Information")
                    {
                    }
                    textelement(jsignature)
                    {
                        XmlName = 'Signature';
                    }

                    trigger OnAfterGetRecord()
                    var
                        POSAuditLog: Record "POS Audit Log";
                    begin
                        POSAuditLog := JETEntry;
                        POSAuditLog.SetRecFilter;
                        JSignature := GetAuditSignature(POSAuditLog);
                    end;

                    trigger OnPreXmlItem()
                    begin
                        JETEntry.SetView(JETFilter);
                    end;
                }
            }

            trigger OnAfterGetRecord()
            var
                LastWorkshiftCheckpoint: Record "POS Workshift Checkpoint";
                POSAuditLog: Record "POS Audit Log";
                InStream: InStream;
                POSAuditLog2: Record "POS Audit Log";
                FromJETEntry: Integer;
                ToJETEntry: Integer;
            begin
                PCheckpoint.TestField(Type, PCheckpoint.Type::PREPORT);
                PCheckpoint.TestField(Open, false);
                PCheckpoint.SetRecFilter; //Only one workshift being archived
                ToZReportEntry := PCheckpoint."Entry No.";
                UnitNo := PCheckpoint."POS Unit No.";

                POSAuditLog2.SetRange("Record ID", PCheckpoint.RecordId);
                POSAuditLog2.SetRange("Action Type", POSAuditLog2."Action Type"::WORKSHIFT_END);
                POSAuditLog2.FindLast;
                ToJETEntry := POSAuditLog2."Entry No.";

                JETEntry.SetRange("Active POS Unit No.", PCheckpoint."POS Unit No.");
                JETEntry.SetRange("External Type", 'JET');

                LastWorkshiftCheckpoint.SetRange("POS Unit No.", PCheckpoint."POS Unit No.");
                LastWorkshiftCheckpoint.SetRange(Type, PCheckpoint.Type);
                LastWorkshiftCheckpoint.SetFilter("Entry No.", '<%1', PCheckpoint."Entry No.");
                if LastWorkshiftCheckpoint.FindLast then begin
                  FromZReportEntry := LastWorkshiftCheckpoint."Entry No.";
                  FromPOSEntry := LastWorkshiftCheckpoint."POS Entry No.";

                  POSAuditLog2.SetRange("Record ID", LastWorkshiftCheckpoint.RecordId);
                  POSAuditLog2.SetRange("Action Type", POSAuditLog2."Action Type"::WORKSHIFT_END);
                  POSAuditLog2.FindLast;
                  FromJETEntry := POSAuditLog2."Entry No.";
                  JETEntry.SetFilter("Entry No.", '>%1&<=%2', FromJETEntry, ToJETEntry);
                end else
                  JETEntry.SetFilter("Entry No.", '<=%1', ToJETEntry);

                JETFilter := JETEntry.GetView(false);

                POSAuditLog.SetRange("Record ID", PCheckpoint.RecordId);
                POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::GRANDTOTAL);
                POSAuditLog.FindFirst;
                PExternalID := POSAuditLog."External ID";
                PPerpetualGrandTotal := POSAuditLog."Additional Information"; //Contains Perpetual for monthly period.
                PSignature := GetAuditSignature(POSAuditLog);
                PGrandTotal := Format(PCheckpoint."Direct Turnover (LCY)" - PCheckpoint."Rounding (LCY)",0,'<Precision,2:2><Standard Format,9>');
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    trigger OnPreXmlPort()
    begin
        FirstPOSEntry := true;
        FirstZReport := true;
    end;

    var
        FromPOSEntry: Integer;
        ToPOSEntry: Integer;
        UnitNo: Code[10];
        FirstPOSEntry: Boolean;
        FirstZReport: Boolean;
        FromZReportEntry: Integer;
        ToZReportEntry: Integer;
        JETFilter: Text;

    local procedure GetAuditSignature(var POSAuditLog: Record "POS Audit Log"): Text
    var
        InStream: InStream;
        Signature: Text;
    begin
        POSAuditLog.SetAutoCalcFields("Electronic Signature");
        POSAuditLog.FindFirst;
        POSAuditLog."Electronic Signature".CreateInStream(InStream);
        while (not InStream.EOS) do
          InStream.Read(Signature);
        exit(Signature);
    end;

    local procedure IsCancelledSale(POSEntry: Record "POS Entry"): Boolean
    var
        SaleLinePOS: Record "Sale Line POS";
        POSAuditLog: Record "POS Audit Log";
    begin
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::DIRECT_SALE_END);
        POSAuditLog.SetRange("Record ID", POSEntry.RecordId);
        exit((POSEntry."Fiscal No." = '') and (POSEntry."No. of Sales Lines" = 0) and (POSEntry."Total Amount Incl. Tax" = 0) and POSAuditLog.IsEmpty);
    end;
}

