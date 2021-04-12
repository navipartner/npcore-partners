xmlport 6184850 "NPR FR Audit Archive"
{
    Caption = 'FR Audit Archive';
    Direction = Export;
    Encoding = UTF8;
    FormatEvaluate = Xml;

    schema
    {
        tableelement(pcheckpoint; "NPR POS Workshift Checkpoint")
        {
            XmlName = 'GrandPeriod';
            textelement(archivesignature)
            {
                XmlName = 'ArchiveFileSignature';
            }
            fieldelement(SystemEntryKey; PCheckpoint."Entry No.")
            {
            }
            textelement(pexternalid)
            {
                XmlName = 'ID';
            }
            fieldelement(CreatedAt; PCheckpoint."Created At")
            {
            }
            textelement(pgrandtotal)
            {
                XmlName = 'GrandTotal';
            }
            textelement(pperpetualabsolutegrandtotal)
            {
                XmlName = 'PerpetualAbsoluteGrandTotal';
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
                tableelement(grandperiodtaxline; "NPR POS Worksh. Tax Checkp.")
                {
                    LinkFields = "Workshift Checkpoint Entry No." = FIELD("Entry No.");
                    LinkTable = PCheckpoint;
                    MinOccurs = Zero;
                    XmlName = 'TaxLine';
                    fieldelement(TaxIdentifier; GrandPeriodTaxLine."VAT Identifier")
                    {
                    }
                    fieldelement(TaxRate; GrandPeriodTaxLine."Tax %")
                    {
                    }
                    fieldelement(TaxBaseAmount; GrandPeriodTaxLine."Tax Base Amount")
                    {
                    }
                    fieldelement(TaxAmount; GrandPeriodTaxLine."Tax Amount")
                    {
                    }
                }
            }
            tableelement(zcheckpoint; "NPR POS Workshift Checkpoint")
            {
                XmlName = 'Period';
                fieldelement(SystemEntryKey; ZCheckpoint."Entry No.")
                {
                }
                textelement(zexternalid)
                {
                    XmlName = 'ID';
                }
                fieldelement(CreatedAt; ZCheckpoint."Created At")
                {
                }
                textelement(zgrandtotal)
                {
                    XmlName = 'GrandTotal';
                }
                textelement(zperpetualabsolutegrandtotal)
                {
                    XmlName = 'PerpetualAbsoluteGrandTotal';
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
                    tableelement(periodtaxline; "NPR POS Worksh. Tax Checkp.")
                    {
                        LinkFields = "Workshift Checkpoint Entry No." = FIELD("Entry No.");
                        LinkTable = ZCheckpoint;
                        MinOccurs = Zero;
                        XmlName = 'TaxLine';
                        fieldelement(TaxIdentifier; PeriodTaxLine."VAT Identifier")
                        {
                        }
                        fieldelement(TaxRate; PeriodTaxLine."Tax %")
                        {
                        }
                        fieldelement(TaxBaseAmount; PeriodTaxLine."Tax Base Amount")
                        {
                        }
                        fieldelement(TaxAmount; PeriodTaxLine."Tax Amount")
                        {
                        }
                    }
                }
                tableelement("POS Entry"; "NPR POS Entry")
                {
                    MinOccurs = Zero;
                    XmlName = 'Ticket';
                    fieldelement(SystemEntryKey; "POS Entry"."Entry No.")
                    {
                    }
                    fieldelement(DocumentNumber; "POS Entry"."Fiscal No.")
                    {
                    }
                    fieldelement(NoOfPrints; "POS Entry"."No. of Print Output Entries")
                    {
                    }
                    fieldelement(SalespersonCode; "POS Entry"."Salesperson Code")
                    {
                    }
                    fieldelement(POSCode; "POS Entry"."POS Unit No.")
                    {
                    }
                    fieldelement(Date; "POS Entry"."Entry Date")
                    {
                    }
                    fieldelement(Time; "POS Entry"."Ending Time")
                    {
                    }
                    fieldelement(OperationType; "POS Entry"."Entry Type")
                    {
                    }
                    textelement(documenttype)
                    {
                        XmlName = 'DocumentType';
                    }
                    fieldelement(NoOfSaleLines; "POS Entry"."No. of Sales Lines")
                    {
                    }
                    textelement(tsignature)
                    {
                        XmlName = 'Signature';
                    }
                    tableelement("FR POS Audit Log Aux. Info"; "NPR FR POS Audit Log Aux. Info")
                    {
                        LinkFields = "POS Entry No." = FIELD("Entry No.");
                        LinkTable = "POS Entry";
                        MaxOccurs = Once;
                        XmlName = 'RelatedInfo';
                        fieldelement(SoftwareVersion; "FR POS Audit Log Aux. Info"."NPR Version")
                        {
                        }
                        fieldelement(StoreName; "FR POS Audit Log Aux. Info"."Store Name")
                        {
                        }
                        fieldelement(StoreName2; "FR POS Audit Log Aux. Info"."Store Name 2")
                        {
                        }
                        fieldelement(StoreAddress; "FR POS Audit Log Aux. Info"."Store Address")
                        {
                        }
                        fieldelement(StoreAddress2; "FR POS Audit Log Aux. Info"."Store Address 2")
                        {
                        }
                        fieldelement(StorePostCode; "FR POS Audit Log Aux. Info"."Store Post Code")
                        {
                        }
                        fieldelement(StoreCity; "FR POS Audit Log Aux. Info"."Store City")
                        {
                        }
                        fieldelement(Siret; "FR POS Audit Log Aux. Info"."Store Siret")
                        {
                        }
                        fieldelement(APE; "FR POS Audit Log Aux. Info".APE)
                        {
                        }
                        fieldelement(IntraCommVATIdentifier; "FR POS Audit Log Aux. Info"."Intra-comm. VAT ID")
                        {
                        }
                        fieldelement(SalespersonName; "FR POS Audit Log Aux. Info"."Salesperson Name")
                        {
                        }
                    }
                    textelement(SalesLines)
                    {
                        tableelement("POS Sales Line"; "NPR POS Entry Sales Line")
                        {
                            LinkFields = "POS Entry No." = FIELD("Entry No.");
                            LinkTable = "POS Entry";
                            MinOccurs = Zero;
                            XmlName = 'SalesLine';
                            fieldelement(LineNo; "POS Sales Line"."Line No.")
                            {
                            }
                            fieldelement(Type; "POS Sales Line".Type)
                            {
                            }
                            fieldelement(ProductCode; "POS Sales Line"."No.")
                            {
                            }
                            fieldelement(ProductLabel; "POS Sales Line".Description)
                            {
                            }
                            fieldelement(Quantity; "POS Sales Line".Quantity)
                            {
                            }
                            fieldelement(TaxIdentifier; "POS Sales Line"."VAT Identifier")
                            {
                            }
                            fieldelement(TaxRate; "POS Sales Line"."VAT %")
                            {
                            }
                            fieldelement(UnitPriceInclTax; "POS Sales Line"."Unit Price")
                            {
                            }
                            fieldelement(DiscountCode; "POS Sales Line"."Discount Code")
                            {
                            }
                            fieldelement(DiscountPercentage; "POS Sales Line"."Line Discount %")
                            {
                            }
                            fieldelement(DiscountAmount; "POS Sales Line"."Line Discount Amount Incl. VAT")
                            {
                            }
                            fieldelement(TotalExclTax; "POS Sales Line"."Amount Excl. VAT")
                            {
                            }
                            fieldelement(TotalInclTax; "POS Sales Line"."Amount Incl. VAT")
                            {
                            }
                            fieldelement(BaseQuantity; "POS Sales Line"."Quantity (Base)")
                            {
                            }
                            fieldelement(UnitOfMeasureCode; "POS Sales Line"."Unit of Measure Code")
                            {
                            }
                        }
                    }
                    textelement(TaxLines)
                    {
                        tableelement("POS Tax Amount Line"; "NPR POS Entry Tax Line")
                        {
                            LinkFields = "POS Entry No." = FIELD("Entry No.");
                            LinkTable = "POS Entry";
                            MinOccurs = Zero;
                            XmlName = 'TaxLine';
                            fieldelement(TaxIdentifier; "POS Tax Amount Line"."VAT Identifier")
                            {
                            }
                            fieldelement(TaxBaseAmount; "POS Tax Amount Line"."Tax Base Amount")
                            {
                            }
                            fieldelement(TaxRate; "POS Tax Amount Line"."Tax %")
                            {
                            }
                            fieldelement(TaxAmount; "POS Tax Amount Line"."Tax Amount")
                            {
                            }
                            fieldelement(AmountInclTax; "POS Tax Amount Line"."Amount Including Tax")
                            {
                            }
                        }
                    }
                    tableelement(ticketgrandtotal; "NPR POS Audit Log")
                    {
                        LinkFields = "Acted on POS Entry No." = FIELD("Entry No.");
                        LinkTable = "POS Entry";
                        MaxOccurs = Once;
                        XmlName = 'TicketTotals';
                        SourceTableView = WHERE("External Type" = CONST('GRANDTOTAL'));
                        fieldelement(TotalInclTax; "POS Entry"."Amount Incl. Tax")
                        {
                        }
                        fieldelement(TotalExclTax; "POS Entry"."Amount Excl. Tax")
                        {
                        }
                        textelement(tgrandtotal)
                        {
                            XmlName = 'GrandTotal';
                        }
                        textelement(tperpetualabsolutegrandtotal)
                        {
                            XmlName = 'PerpetualAbsoluteGrandTotal';
                        }
                        textelement(tperpetualgrandtotal)
                        {
                            XmlName = 'PerpetualGrandTotal';
                        }
                        textelement(ttsignature)
                        {
                            XmlName = 'GrandTotalSignature';
                        }

                        trigger OnAfterGetRecord()
                        var
                            POSAuditLog: Record "NPR POS Audit Log";
                        begin
                            POSAuditLog.SetRange("Record ID", "POS Entry".RecordId);
                            POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::GRANDTOTAL);
                            TTSignature := GetAuditSignature(POSAuditLog);
                            TGrandTotal := GetSplitStringValue(POSAuditLog."Additional Information", '|', 1);
                            TPerpetualAbsoluteGrandTotal := GetSplitStringValue(POSAuditLog."Additional Information", '|', 2);
                            TPerpetualGrandTotal := GetSplitStringValue(POSAuditLog."Additional Information", '|', 3);
                        end;
                    }
                    textelement(PaymentLines)
                    {
                        tableelement("POS Payment Line"; "NPR POS Entry Payment Line")
                        {
                            LinkFields = "POS Entry No." = FIELD("Entry No.");
                            LinkTable = "POS Entry";
                            MinOccurs = Zero;
                            XmlName = 'PaymentLine';
                            fieldelement(Code; "POS Payment Line"."POS Payment Method Code")
                            {
                            }
                            textelement(paymentlinetype)
                            {
                                XmlName = 'Type';
                            }
                            fieldelement(Description; "POS Payment Line".Description)
                            {
                            }
                            fieldelement(Amount; "POS Payment Line"."Amount (LCY)")
                            {
                            }
                            fieldelement(Currency; "POS Payment Line"."Currency Code")
                            {
                            }
                            fieldelement(CurrencyAmount; "POS Payment Line"."Amount (Sales Currency)")
                            {
                            }
                            textelement(paymentlineexchrate)
                            {
                                XmlName = 'ExchangeRate';
                            }

                            trigger OnAfterGetRecord()
                            var
                                POSPaymentMethod: Record "NPR POS Payment Method";
                            begin

                                POSPaymentMethod.Get("POS Payment Line"."POS Payment Method Code");

                                PaymentLineType := Format(POSPaymentMethod."Processing Type");
                                PaymentLineExchRate := Format(Round("POS Payment Line"."Amount (LCY)" / "POS Payment Line"."Amount (Sales Currency)", 0.00001, '='));
                            end;
                        }
                    }
                    textelement(PrintDuplicates)
                    {
                        tableelement("POS Entry Output Log"; "NPR POS Entry Output Log")
                        {
                            LinkFields = "POS Entry No." = FIELD("Entry No.");
                            LinkTable = "POS Entry";
                            MinOccurs = Zero;
                            XmlName = 'PrintDuplicate';
                            SourceTableView = WHERE("Output Method" = CONST(Print), "Output Type" = FILTER(SalesReceipt | LargeSalesReceipt));
                            textelement(outputexternalid)
                            {
                                XmlName = 'ID';
                            }
                            textelement(outputreprintnumber)
                            {
                                XmlName = 'ReprintNumber';
                            }
                            fieldelement(SalespersonCode; "POS Entry Output Log"."Salesperson Code")
                            {
                            }
                            fieldelement(UserCode; "POS Entry Output Log"."User ID")
                            {
                            }
                            fieldelement(Timestamp; "POS Entry Output Log"."Output Timestamp")
                            {
                            }
                            textelement(outputsignature)
                            {
                                XmlName = 'Signature';
                            }

                            trigger OnAfterGetRecord()
                            var
                                POSAuditLog: Record "NPR POS Audit Log";
                            begin
                                POSAuditLog.SetRange("Record ID", "POS Entry Output Log".RecordId);
                                POSAuditLog.SetFilter("Action Type", '=%1|=%2', POSAuditLog."Action Type"::RECEIPT_COPY, POSAuditLog."Action Type"::RECEIPT_PRINT);
                                POSAuditLog.FindFirst();

                                if POSAuditLog."Action Type" = POSAuditLog."Action Type"::RECEIPT_PRINT then
                                    currXMLport.Skip();

                                OutputExternalID := POSAuditLog."External ID";
                                OutputReprintNumber := POSAuditLog."Additional Information"; //Contains reprint no.
                                OutputSignature := GetAuditSignature(POSAuditLog);
                            end;
                        }
                    }
                    textelement(AssociatedDocuments)
                    {
                        tableelement(issuedgenericvoucher; "NPR NpRv Voucher Entry")
                        {
                            LinkFields = "Register No." = FIELD("POS Unit No."), "Document No." = FIELD("Document No.");
                            LinkTable = "POS Entry";
                            MinOccurs = Zero;
                            XmlName = 'IssuedGenericVoucher';
                            SourceTableView = WHERE("Entry Type" = CONST("Issue Voucher"));
                            fieldelement(VoucherNo; IssuedGenericVoucher."Voucher No.")
                            {
                            }
                            fieldelement(VoucherType; IssuedGenericVoucher."Voucher Type")
                            {
                            }
                            fieldelement(Amount; IssuedGenericVoucher.Amount)
                            {
                            }
                        }
                        tableelement(appliedgenericvoucher; "NPR NpRv Voucher Entry")
                        {
                            LinkFields = "Register No." = FIELD("POS Unit No."), "Document No." = FIELD("Document No.");
                            LinkTable = "POS Entry";
                            MinOccurs = Zero;
                            XmlName = 'AppliedGenericVoucher';
                            SourceTableView = WHERE("Entry Type" = CONST(Payment));
                            fieldelement(VoucherNo; AppliedGenericVoucher."Voucher No.")
                            {
                            }
                            fieldelement(VoucherType; AppliedGenericVoucher."Voucher Type")
                            {
                            }
                            fieldelement(AppliedAmount; AppliedGenericVoucher.Amount)
                            {
                            }
                            fieldelement(RemainingAmount; AppliedGenericVoucher."Remaining Amount")
                            {
                            }
                        }
                        tableelement(issuedcoupon; "NPR NpDc Coupon Entry")
                        {
                            LinkFields = "Register No." = FIELD("POS Unit No."), "Document No." = FIELD("Document No.");
                            LinkTable = "POS Entry";
                            MinOccurs = Zero;
                            XmlName = 'IssuedCoupon';
                            SourceTableView = WHERE("Entry Type" = CONST("Issue Coupon"), "Document Type" = CONST("POS Entry"));
                            fieldelement(CouponNo; IssuedCoupon."Coupon No.")
                            {
                            }
                            fieldelement(CouponType; IssuedCoupon."Coupon Type")
                            {
                            }
                            fieldelement(Quantity; IssuedCoupon.Quantity)
                            {
                            }
                            fieldelement(AmountPerQuantity; IssuedCoupon."Amount per Qty.")
                            {
                            }
                        }
                        tableelement(appliedcoupon; "NPR NpDc Coupon Entry")
                        {
                            LinkFields = "Register No." = FIELD("POS Unit No."), "Document No." = FIELD("Document No.");
                            LinkTable = "POS Entry";
                            MinOccurs = Zero;
                            XmlName = 'AppliedCoupon';
                            SourceTableView = WHERE("Entry Type" = CONST("Discount Application"), "Document Type" = CONST("POS Entry"));
                            fieldelement(CouponNo; AppliedCoupon."Coupon No.")
                            {
                            }
                            fieldelement(CouponType; AppliedCoupon."Coupon Type")
                            {
                            }
                            fieldelement(AppliedQuantity; AppliedCoupon.Quantity)
                            {
                            }
                            fieldelement(RemainingQuantity; AppliedCoupon."Remaining Quantity")
                            {
                            }
                            fieldelement(AmountPerQuantity; AppliedCoupon."Amount per Qty.")
                            {
                            }
                        }
                    }

                    trigger OnAfterGetRecord()
                    var
                        POSAuditLog: Record "NPR POS Audit Log";
                    begin
                        POSAuditLog.SetRange("Record ID", "POS Entry".RecordId);
                        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::DIRECT_SALE_END);
                        POSAuditLog.FindFirst();
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
                    POSAuditLog: Record "NPR POS Audit Log";
                    LastZReport: Record "NPR POS Workshift Checkpoint";
                begin
                    if LastZReportEntryNo <> 0 then begin
                        LastZReport.Get(LastZReportEntryNo);
                        FromPOSEntry := LastZReport."POS Entry No.";
                    end;
                    ToPOSEntry := ZCheckpoint."POS Entry No.";

                    POSAuditLog.SetRange("Record ID", ZCheckpoint.RecordId);
                    POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::GRANDTOTAL);
                    POSAuditLog.FindFirst();
                    ZExternalID := POSAuditLog."External ID";
                    ZSignature := GetAuditSignature(POSAuditLog);
                    ZGrandTotal := GetSplitStringValue(POSAuditLog."Additional Information", '|', 1);
                    ZPerpetualAbsoluteGrandTotal := GetSplitStringValue(POSAuditLog."Additional Information", '|', 2);
                    ZPerpetualGrandTotal := GetSplitStringValue(POSAuditLog."Additional Information", '|', 3);


                    LastZReportEntryNo := ZCheckpoint."Entry No.";
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
                tableelement(jetentry; "NPR POS Audit Log")
                {
                    XmlName = 'JETEntry';
                    fieldelement(ID; JETEntry."External ID")
                    {
                    }
                    fieldelement(Code; JETEntry."External Code")
                    {
                    }
                    fieldelement(Description; JETEntry."External Description")
                    {
                    }
                    fieldelement(Salesperson; JETEntry."Active Salesperson Code")
                    {
                    }
                    fieldelement(Timestamp; JETEntry."Log Timestamp")
                    {
                    }
                    fieldelement(AdditionalInfo; JETEntry."Additional Information")
                    {
                    }
                    textelement(jsignature)
                    {
                        XmlName = 'Signature';
                    }

                    trigger OnAfterGetRecord()
                    var
                        POSAuditLog: Record "NPR POS Audit Log";
                    begin
                        POSAuditLog := JETEntry;
                        POSAuditLog.SetRecFilter();
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
                LastWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
                POSAuditLog: Record "NPR POS Audit Log";
                POSAuditLog2: Record "NPR POS Audit Log";
                FromJETEntry: Integer;
                ToJETEntry: Integer;
                FRAuditMgt: Codeunit "NPR FR Audit Mgt.";
            begin
                //Find last checkpoint to set interval filter correctly for both JET entries, POS entries and Z report entries.

                PCheckpoint.TestField(Type, PCheckpoint.Type::PREPORT);
                PCheckpoint.TestField(Open, false);
                PCheckpoint.SetRecFilter(); //Only one workshift being archived
                ToZReportEntry := PCheckpoint."Entry No.";
                UnitNo := PCheckpoint."POS Unit No.";

                POSAuditLog2.SetRange("Record ID", PCheckpoint.RecordId);
                POSAuditLog2.SetRange("Action Type", POSAuditLog2."Action Type"::WORKSHIFT_END);
                POSAuditLog2.SetRange("Acted on POS Unit No.", PCheckpoint."POS Unit No.");
                POSAuditLog2.FindLast();
                ToJETEntry := POSAuditLog2."Entry No.";

                JETEntry.SetRange("Active POS Unit No.", PCheckpoint."POS Unit No.");
                JETEntry.SetRange("External Type", 'JET');

                LastWorkshiftCheckpoint.SetRange("POS Unit No.", PCheckpoint."POS Unit No.");
                LastWorkshiftCheckpoint.SetRange(Type, PCheckpoint.Type);
                LastWorkshiftCheckpoint.SetRange("Period Type", PCheckpoint."Period Type");
                LastWorkshiftCheckpoint.SetRange(Open, false);
                LastWorkshiftCheckpoint.SetFilter("Entry No.", '<%1', PCheckpoint."Entry No.");
                if LastWorkshiftCheckpoint.FindLast() then begin
                    POSAuditLog2.SetRange("Record ID", LastWorkshiftCheckpoint.RecordId);
                    POSAuditLog2.SetRange("Action Type", POSAuditLog2."Action Type"::WORKSHIFT_END);
                    if POSAuditLog2.FindLast() then begin
                        FromZReportEntry := LastWorkshiftCheckpoint."Entry No.";
                        FromPOSEntry := LastWorkshiftCheckpoint."POS Entry No.";

                        FromJETEntry := POSAuditLog2."Entry No.";
                        JETEntry.SetFilter("Entry No.", '>%1&<=%2', FromJETEntry, ToJETEntry);
                    end;
                end;

                if FromJETEntry = 0 then begin
                    //Set filters to oldest entries after JET init

                    POSAuditLog2.Reset();
                    FRAuditMgt.GetJETInitRecord(POSAuditLog2, UnitNo, true);
                    POSAuditLog2.Reset();
                    POSAuditLog2.SetFilter("Entry No.", '>%1', POSAuditLog2."Entry No.");
                    POSAuditLog2.SetRange("Acted on POS Unit No.", PCheckpoint."POS Unit No.");

                    POSAuditLog2.SetRange("Action Type", POSAuditLog2."Action Type"::DIRECT_SALE_END);
                    POSAuditLog2.FindFirst();
                    FromPOSEntry := POSAuditLog2."Acted on POS Entry No.";

                    POSAuditLog2.SetRange("Action Type", POSAuditLog2."Action Type"::DRAWER_COUNT);
                    POSAuditLog2.FindFirst();
                    LastWorkshiftCheckpoint.Reset();
                    LastWorkshiftCheckpoint.Get(POSAuditLog2."Record ID");
                    FromZReportEntry := LastWorkshiftCheckpoint."Entry No.";
                    JETEntry.SetFilter("Entry No.", '<=%1', ToJETEntry);
                end;

                JETFilter := JETEntry.GetView(false);

                POSAuditLog.SetRange("Record ID", PCheckpoint.RecordId);
                POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::GRANDTOTAL);
                POSAuditLog.FindFirst();
                PExternalID := POSAuditLog."External ID";
                PSignature := GetAuditSignature(POSAuditLog);
                PGrandTotal := GetSplitStringValue(POSAuditLog."Additional Information", '|', 1);
                PPerpetualAbsoluteGrandTotal := GetSplitStringValue(POSAuditLog."Additional Information", '|', 2);
                PPerpetualGrandTotal := GetSplitStringValue(POSAuditLog."Additional Information", '|', 3);

                POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::ARCHIVE_CREATE);
                ArchiveSignature := GetAuditSignature(POSAuditLog);
            end;
        }
    }

    var
        LastZReportEntryNo: Integer;
        FromPOSEntry: Integer;
        ToPOSEntry: Integer;
        UnitNo: Code[10];
        FromZReportEntry: Integer;
        ToZReportEntry: Integer;
        JETFilter: Text;

    local procedure GetAuditSignature(var POSAuditLog: Record "NPR POS Audit Log"): Text
    var
        InStream: InStream;
        Signature: Text;
    begin
        POSAuditLog.SetAutoCalcFields("Electronic Signature");
        POSAuditLog.FindFirst();
        POSAuditLog."Electronic Signature".CreateInStream(InStream);
        while (not InStream.EOS) do
            InStream.Read(Signature);
        exit(Signature);
    end;

    local procedure GetSplitStringValue(Value: Text; Separator: Char; Index: Integer): Text
    var
        String: Text;
        SplitArray: List of [Text];
    begin
        String := Value;
        SplitArray := String.Split(Separator);
        exit(SplitArray.Get(Index));
    end;
}