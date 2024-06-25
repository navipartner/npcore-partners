xmlport 6184850 "NPR FR Audit Archive"
{
    Caption = 'FR Audit Archive';
    Direction = Export;
    Encoding = UTF8;
    FormatEvaluate = Xml;

    schema
    {
        textelement(Archive)
        {
            XmlName = 'Archive';

            tableelement(pcheckpoint; "NPR POS Workshift Checkpoint")
            {
                XmlName = 'GrandPeriod';
                textelement(archivesignature)
                {
                    XmlName = 'ArchiveSignature';
                }
                fieldelement(SystemEntryKey; PCheckpoint."Entry No.")
                {
                    XmlName = 'SystemEntryNo';
                }
                textelement(pexternalid)
                {
                    XmlName = 'SequentialID';
                }
                textelement(pfromdate)
                {
                    XmlName = 'FromDate';
                }
                textelement(ptodate)
                {
                    XmlName = 'ToDate';
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
                    XmlName = 'PeriodGrandTotalSignature';
                }

                textelement(tickets)
                {
                    XmlName = 'Tickets';
                    tableelement(ticket; "NPR POS Audit Log")
                    {
                        MinOccurs = Zero;
                        XmlName = 'Ticket';

                        tableelement(ticket_pos_entry; "NPR POS Entry")
                        {
                            MinOccurs = Once;
                            MaxOccurs = Once;
                            fieldelement(SystemEntryKey; ticket_pos_entry."Entry No.")
                            {
                            }
                            fieldelement(DocumentNumber; ticket_pos_entry."Fiscal No.")
                            {
                            }
                            fieldelement(NoOfPrints; ticket_pos_entry."No. of Print Output Entries")
                            {
                            }
                            fieldelement(SalespersonCode; ticket_pos_entry."Salesperson Code")
                            {
                            }
                            fieldelement(POSCode; ticket_pos_entry."POS Unit No.")
                            {
                            }
                            fieldelement(Date; ticket_pos_entry."Entry Date")
                            {
                            }
                            fieldelement(Time; ticket_pos_entry."Ending Time")
                            {
                            }
                            fieldelement(OperationType; ticket_pos_entry."Entry Type")
                            {
                            }
                            textelement(documenttype)
                            {
                                XmlName = 'DocumentType';
                            }
                            textelement(documenttypedescription)
                            {
                                XmlName = 'DocumentTypeDescription';
                            }
                            fieldelement(NoOfSaleLines; ticket_pos_entry."No. of Sales Lines")
                            {
                            }
                            fieldelement(TotalInclTax; ticket_pos_entry."Amount Incl. Tax")
                            {
                            }
                            fieldelement(TotalExclTax; ticket_pos_entry."Amount Excl. Tax")
                            {
                            }
                            fieldelement(TotalDiscountInclTax; ticket_pos_entry."Discount Amount Incl. VAT")
                            {
                            }
                            textelement(tsignature)
                            {
                                XmlName = 'TicketSignature';
                            }
                            textelement(SalesLines)
                            {
                                tableelement("POS Sales Line"; "NPR POS Entry Sales Line")
                                {
                                    LinkFields = "POS Entry No." = FIELD("Entry No.");
                                    LinkTable = ticket_pos_entry;
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
                                    textelement(possaleslinecreatedat)
                                    {
                                        XmlName = 'CreatedAt';
                                    }
                                    trigger OnAfterGetRecord()
                                    begin
                                        possaleslinecreatedat := Format("POS Sales Line"."POS Sale Line Created At", 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2><Second dec.><Comma,.>Z');
                                    end;
                                }
                            }
                            textelement(TaxLines)
                            {
                                tableelement("POS Tax Amount Line"; "NPR POS Entry Tax Line")
                                {
                                    LinkFields = "POS Entry No." = FIELD("Entry No.");
                                    LinkTable = ticket_pos_entry;
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

                            textelement(PaymentLines)
                            {
                                tableelement("POS Payment Line"; "NPR POS Entry Payment Line")
                                {
                                    LinkFields = "POS Entry No." = FIELD("Entry No.");
                                    LinkTable = ticket_pos_entry;
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
                                    textelement(pospaymentlinecreatedat)
                                    {
                                        XmlName = 'CreatedAt';
                                    }

                                    trigger OnAfterGetRecord()
                                    var
                                        POSPaymentMethod: Record "NPR POS Payment Method";
                                    begin

                                        POSPaymentMethod.Get("POS Payment Line"."POS Payment Method Code");

                                        PaymentLineType := Format(POSPaymentMethod."Processing Type");
                                        PaymentLineExchRate := Format(Round("POS Payment Line"."Amount (LCY)" / "POS Payment Line"."Amount (Sales Currency)", 0.00001, '='));

                                        pospaymentlinecreatedat := Format("POS Payment Line"."POS Payment Line Created At", 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2><Second dec.><Comma,.>Z');
                                    end;
                                }
                            }

                            textelement(AssociatedDocuments)
                            {
                                tableelement(issuedgenericvoucher; "NPR NpRv Voucher Entry")
                                {
                                    LinkFields = "Register No." = FIELD("POS Unit No."), "Document No." = FIELD("Document No.");
                                    LinkTable = ticket_pos_entry;
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
                                tableelement(archivedissuedgenericvoucher; "NPR NpRv Arch. Voucher Entry")
                                {
                                    LinkFields = "Register No." = FIELD("POS Unit No."), "Document No." = FIELD("Document No.");
                                    LinkTable = ticket_pos_entry;
                                    MinOccurs = Zero;
                                    XmlName = 'IssuedGenericVoucher';
                                    SourceTableView = WHERE("Entry Type" = CONST("Issue Voucher"));
                                    fieldelement(VoucherNo; archivedIssuedGenericVoucher."Arch. Voucher No.")
                                    {
                                    }
                                    fieldelement(VoucherType; archivedIssuedGenericVoucher."Voucher Type")
                                    {
                                    }
                                    fieldelement(Amount; archivedIssuedGenericVoucher.Amount)
                                    {
                                    }
                                }
                                tableelement(appliedgenericvoucher; "NPR NpRv Voucher Entry")
                                {
                                    LinkFields = "Register No." = FIELD("POS Unit No."), "Document No." = FIELD("Document No.");
                                    LinkTable = ticket_pos_entry;
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
                                tableelement(archivedappliedgenericvoucher; "NPR NpRv Arch. Voucher Entry")
                                {
                                    LinkFields = "Register No." = FIELD("POS Unit No."), "Document No." = FIELD("Document No.");
                                    LinkTable = ticket_pos_entry;
                                    MinOccurs = Zero;
                                    XmlName = 'AppliedGenericVoucher';
                                    SourceTableView = WHERE("Entry Type" = CONST(Payment));
                                    fieldelement(VoucherNo; archivedAppliedGenericVoucher."Arch. Voucher No.")
                                    {
                                    }
                                    fieldelement(VoucherType; archivedAppliedGenericVoucher."Voucher Type")
                                    {
                                    }
                                    fieldelement(AppliedAmount; archivedAppliedGenericVoucher.Amount)
                                    {
                                    }
                                    fieldelement(RemainingAmount; archivedAppliedGenericVoucher."Remaining Amount")
                                    {
                                    }
                                }
                                tableelement(issuedcoupon; "NPR NpDc Coupon Entry")
                                {
                                    LinkFields = "Register No." = FIELD("POS Unit No."), "Document No." = FIELD("Document No.");
                                    LinkTable = ticket_pos_entry;
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
                                tableelement(archivedissuedcoupon; "NPR NpDc Arch.Coupon Entry")
                                {
                                    LinkFields = "Register No." = FIELD("POS Unit No."), "Document No." = FIELD("Document No.");
                                    LinkTable = ticket_pos_entry;
                                    MinOccurs = Zero;
                                    XmlName = 'IssuedCoupon';
                                    SourceTableView = WHERE("Entry Type" = CONST("Issue Coupon"), "Document Type" = CONST("POS Entry"));
                                    fieldelement(CouponNo; archivedIssuedCoupon."Arch. Coupon No.")
                                    {
                                    }
                                    fieldelement(CouponType; archivedIssuedCoupon."Coupon Type")
                                    {
                                    }
                                    fieldelement(Quantity; archivedIssuedCoupon.Quantity)
                                    {
                                    }
                                    fieldelement(AmountPerQuantity; archivedIssuedCoupon."Amount per Qty.")
                                    {
                                    }
                                }
                                tableelement(appliedcoupon; "NPR NpDc Coupon Entry")
                                {
                                    LinkFields = "Register No." = FIELD("POS Unit No."), "Document No." = FIELD("Document No.");
                                    LinkTable = ticket_pos_entry;
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
                                tableelement(archivedappliedcoupon; "NPR NpDc Arch.Coupon Entry")
                                {
                                    LinkFields = "Register No." = FIELD("POS Unit No."), "Document No." = FIELD("Document No.");
                                    LinkTable = ticket_pos_entry;
                                    MinOccurs = Zero;
                                    XmlName = 'AppliedCoupon';
                                    SourceTableView = WHERE("Entry Type" = CONST("Discount Application"), "Document Type" = CONST("POS Entry"));
                                    fieldelement(CouponNo; archivedAppliedCoupon."Arch. Coupon No.")
                                    {
                                    }
                                    fieldelement(CouponType; archivedAppliedCoupon."Coupon Type")
                                    {
                                    }
                                    fieldelement(AppliedQuantity; archivedAppliedCoupon.Quantity)
                                    {
                                    }
                                    fieldelement(RemainingQuantity; archivedAppliedCoupon."Remaining Quantity")
                                    {
                                    }
                                    fieldelement(AmountPerQuantity; archivedAppliedCoupon."Amount per Qty.")
                                    {
                                    }
                                }
                            }
                            tableelement(ticket_additional_info; "NPR FR POS Audit Log Add. Info")
                            {
                                MinOccurs = Zero;
                                MaxOccurs = Once;
                                XmlName = 'RelatedInfo';
                                fieldelement(SoftwareVersion; ticket_additional_info."NPR Version")
                                {
                                }
                                fieldelement(StoreName; ticket_additional_info."Store Name")
                                {
                                }
                                fieldelement(StoreName2; ticket_additional_info."Store Name 2")
                                {
                                }
                                fieldelement(StoreAddress; ticket_additional_info."Store Address")
                                {
                                }
                                fieldelement(StoreAddress2; ticket_additional_info."Store Address 2")
                                {
                                }
                                fieldelement(StorePostCode; ticket_additional_info."Store Post Code")
                                {
                                }
                                fieldelement(StoreCity; ticket_additional_info."Store City")
                                {
                                }
                                fieldelement(StoreCountry; ticket_additional_info."Store Country/Region Code")
                                {
                                }
                                fieldelement(Siret; ticket_additional_info."Store Siret")
                                {
                                }
                                fieldelement(APE; ticket_additional_info.APE)
                                {
                                }
                                fieldelement(IntraCommVATIdentifier; ticket_additional_info."Intra-comm. VAT ID")
                                {
                                }
                                fieldelement(SalespersonName; ticket_additional_info."Salesperson Name")
                                {
                                }

                                trigger OnPreXmlItem()
                                begin
                                    ticket_additional_info.SetRange("POS Audit Log Entry No.", ticket."Entry No.");
                                end;

                            }

                            trigger OnAfterGetRecord()
                            var
                                POSAuditLog: Record "NPR POS Audit Log";
                            begin
                                POSAuditLog.SetRange("Record ID", ticket_pos_entry.RecordId);
                                POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::DIRECT_SALE_END);
                                POSAuditLog.FindFirst(); //ticket_pos_entry started from entry 1, looks like filter was not applied.
                                DocumentType := POSAuditLog."External Type";
                                documenttypedescription := POSAuditLog."External Description";
                                TSignature := GetAuditSignature(POSAuditLog);
                            end;

                            trigger OnPreXmlItem()
                            var
                                RecRef: RecordRef;
                                POSEntry: Record "NPR POS Entry";
                            begin
                                RecRef.GetTable(POSEntry);
                                RecRef.Get(ticket."Record ID");
                                RecRef.SetTable(POSEntry);
                                ticket_pos_entry := POSEntry;
                                ticket_pos_entry.SetRecFilter();
                            end;
                        }

                        trigger OnPreXmlItem()
                        begin
                            ticket.SetRange("Entry No.", _FromPOSAuditLogEntryNo, _ToPOSAuditLogEntryNo);
                            ticket.SetRange("Acted on POS Unit No.", _POSUnitNo);
                            ticket.SetRange("Action Type", ticket."Action Type"::DIRECT_SALE_END);
                        end;

                    }
                }
                textelement(duplicates)
                {
                    XmlName = 'Duplicates';
                    tableelement(duplicate; "NPR POS Audit Log")
                    {
                        XmlName = 'Duplicate';
                        MinOccurs = Zero;
                        tableelement(POSEntryOutputLog; "NPR POS Entry Output Log")
                        {
                            LinkFields = "POS Entry No." = FIELD("Acted on POS Entry No.");
                            LinkTable = duplicate;
                            MinOccurs = Once;
                            MaxOccurs = Once;
                            SourceTableView = WHERE("Output Method" = CONST(Print), "Output Type" = FILTER(SalesReceipt | LargeSalesReceipt));
                            textelement(outputexternalid)
                            {
                                XmlName = 'ID';
                            }
                            textelement(fiscaldocumentno)
                            {
                                XmlName = 'FiscalDocumentNumber';
                            }
                            textelement(outputreprintnumber)
                            {
                                XmlName = 'ReprintNumber';
                            }
                            fieldelement(SalespersonCode; POSEntryOutputLog."Salesperson Code")
                            {
                            }
                            fieldelement(UserCode; POSEntryOutputLog."User ID")
                            {
                            }
                            textelement(posentryoutputlogtimestamp)
                            {
                                XmlName = 'Timestamp';
                            }
                            textelement(outputsignature)
                            {
                                XmlName = 'DuplicateSignature';
                            }

                            trigger OnPreXmlItem()
                            var
                                RecRef: RecordRef;
                            begin
                                RecRef.Get(duplicate."Record ID");
                                RecRef.SetTable(POSEntryOutputLog);
                                POSEntryOutputLog.SetRecFilter();
                            end;

                            trigger OnAfterGetRecord()
                            var
                                POSAuditLog: Record "NPR POS Audit Log";
                            begin
                                OutputExternalID := duplicate."External ID";
                                OutputReprintNumber := duplicate."Additional Information"; //Contains reprint no.
                                POSAuditLog := duplicate;
                                POSAuditLog.SetRecFilter();
                                OutputSignature := GetAuditSignature(POSAuditLog);
                                fiscaldocumentno := duplicate."Acted on POS Entry Fiscal No.";
                                posentryoutputlogtimestamp := Format(POSEntryOutputLog."Output Timestamp", 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2><Second dec.><Comma,.>Z');
                            end;
                        }
                        tableelement(duplicate_additional_info; "NPR FR POS Audit Log Add. Info")
                        {
                            LinkTable = duplicate;
                            LinkFields = "POS Audit Log Entry No." = FIELD("Entry No.");
                            MinOccurs = Zero;
                            MaxOccurs = Once;
                            XmlName = 'RelatedInfo';
                            fieldelement(SoftwareVersion; duplicate_additional_info."NPR Version")
                            {
                            }
                            fieldelement(StoreName; duplicate_additional_info."Store Name")
                            {
                            }
                            fieldelement(StoreName2; duplicate_additional_info."Store Name 2")
                            {
                            }
                            fieldelement(StoreAddress; duplicate_additional_info."Store Address")
                            {
                            }
                            fieldelement(StoreAddress2; duplicate_additional_info."Store Address 2")
                            {
                            }
                            fieldelement(StorePostCode; duplicate_additional_info."Store Post Code")
                            {
                            }
                            fieldelement(StoreCity; duplicate_additional_info."Store City")
                            {
                            }
                            fieldelement(StoreCountry; duplicate_additional_info."Store Country/Region Code")
                            {
                            }
                            fieldelement(Siret; duplicate_additional_info."Store Siret")
                            {
                            }
                            fieldelement(APE; duplicate_additional_info.APE)
                            {
                            }
                            fieldelement(IntraCommVATIdentifier; duplicate_additional_info."Intra-comm. VAT ID")
                            {
                            }
                            fieldelement(SalespersonName; duplicate_additional_info."Salesperson Name")
                            {
                            }
                        }

                        trigger OnPreXmlItem()
                        begin
                            duplicate.SetRange("Entry No.", _FromPOSAuditLogEntryNo, _ToPOSAuditLogEntryNo);
                            duplicate.SetRange("Acted on POS Unit No.", _POSUnitNo);
                            duplicate.SetRange("Action Type", duplicate."Action Type"::RECEIPT_COPY);
                        end;
                    }
                }
                textelement(grandtotals)
                {
                    XmlName = 'GrandTotals';
                    tableelement(grandtotal; "NPR POS Audit Log")
                    {
                        XmlName = 'GrandTotal';
                        MinOccurs = Zero;

                        fieldelement(GrandTotalType; grandtotal."Action Custom Subtype")
                        {
                        }
                        fieldelement(SequenceNumber; grandtotal."External ID")
                        {
                        }
                        textelement(grandtotalcreatedat)
                        {
                            XmlName = 'CreatedAt';
                        }
                        textelement(grandtotalinclvat)
                        {
                            XmlName = 'GrandTotal';
                        }
                        textelement(perpetualabsolutegrandtotal)
                        {
                            XmlName = 'PerpetualAbsoluteGrandTotal';
                        }
                        textelement(perpetualgrandtotal)
                        {
                            XmlName = 'PerpetualGrandTotal';
                        }
                        textelement(grandtotalsignature)
                        {
                            XmlName = 'GrandTotalSignature';
                        }

                        trigger OnAfterGetRecord()
                        var
                            POSAuditLog: Record "NPR POS Audit Log";
                        begin
                            POSAuditLog := grandtotal;
                            POSAuditLog.SetRecFilter();
                            grandtotalsignature := GetAuditSignature(POSAuditLog);
                            grandtotalinclvat := GetSplitStringValue(grandtotal."Additional Information", '|', 1);
                            perpetualabsolutegrandtotal := GetSplitStringValue(grandtotal."Additional Information", '|', 2);
                            perpetualgrandtotal := GetSplitStringValue(grandtotal."Additional Information", '|', 3);
                            grandtotalcreatedat := Format(grandtotal."Log Timestamp", 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2><Second dec.><Comma,.>Z');
                        end;

                        trigger OnPreXmlItem()
                        begin
                            grandtotal.SetRange("Entry No.", _FromPOSAuditLogEntryNo, _ToPOSAuditLogEntryNo);
                            grandtotal.SetRange("Acted on POS Unit No.", _POSUnitNo);
                            grandtotal.SetRange("Action Type", grandtotal."Action Type"::GRANDTOTAL);
                        end;
                    }
                }
                textelement(jet)
                {
                    XmlName = 'JET';
                    tableelement(jet_entry; "NPR POS Audit Log")
                    {
                        XmlName = 'JETEntry';
                        MinOccurs = Zero;

                        fieldelement(ID; jet_entry."External ID")
                        {
                        }
                        fieldelement(Code; jet_entry."External Code")
                        {
                        }
                        fieldelement(Description; jet_entry."External Description")
                        {
                        }
                        fieldelement(Salesperson; jet_entry."Active Salesperson Code")
                        {
                        }
                        textelement(jetentrytimestamp)
                        {
                            XmlName = 'Timestamp';
                        }
                        fieldelement(AdditionalInfo; jet_entry."Additional Information")
                        {
                        }
                        textelement(jsignature)
                        {
                            XmlName = 'JETSignature';
                        }

                        trigger OnAfterGetRecord()
                        var
                            POSAuditLog: Record "NPR POS Audit Log";
                        begin
                            POSAuditLog := jet_entry;
                            POSAuditLog.SetRecFilter();
                            JSignature := GetAuditSignature(POSAuditLog);
                            jetentrytimestamp := Format(jet_entry."Log Timestamp", 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2><Second dec.><Comma,.>Z');
                        end;

                        trigger OnPreXmlItem()
                        begin
                            jet_entry.SetRange("Entry No.", _FromPOSAuditLogEntryNo, _ToPOSAuditLogEntryNo);
                            jet_entry.SetRange("Acted on POS Unit No.", _POSUnitNo);
                            jet_entry.SetFilter("Action Type", '%1|%2|%3|%4|%5|%6|%7|%8|%9|%10|%11',
                                jet_entry."Action Type"::ARCHIVE_ATTEMPT,
                                jet_entry."Action Type"::SIGN_IN,
                                jet_entry."Action Type"::WORKSHIFT_END,
                                jet_entry."Action Type"::DRAWER_COUNT,
                                jet_entry."Action Type"::PARTNER_MODIFICATION,
                                jet_entry."Action Type"::LOG_INIT,
                                jet_entry."Action Type"::AUDIT_VERIFY_ERROR,
                                jet_entry."Action Type"::CANCEL_SALE_END,
                                jet_entry."Action Type"::SIGN_OUT,
                                jet_entry."Action Type"::ITEM_RMA,
                                jet_entry."Action Type"::CUSTOM);
                        end;
                    }
                }

                trigger OnAfterGetRecord()
                var
                    POSAuditLog: Record "NPR POS Audit Log";
                begin
                    PCheckpoint.TestField(Type, PCheckpoint.Type::PREPORT);
                    PCheckpoint.TestField(Open, false);
                    PCheckpoint.SetRecFilter();

                    POSAuditLog.SetRange("Record ID", PCheckpoint.RecordId);
                    POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::GRANDTOTAL);
                    POSAuditLog.FindLast();

                    //Set globals and top level tableelement fields
                    _POSUnitNo := PCheckpoint."POS Unit No.";
                    _ToPOSAuditLogEntryNo := POSAuditLog."Entry No.";
                    _PeriodType := POSAuditLog."Action Custom Subtype";
                    ptodate := Format(DT2Date(POSAuditLog.SystemCreatedAt), 0, 9);
                    PExternalID := POSAuditLog."External ID";
                    PSignature := GetAuditSignature(POSAuditLog);
                    PGrandTotal := GetSplitStringValue(POSAuditLog."Additional Information", '|', 1);
                    PPerpetualAbsoluteGrandTotal := GetSplitStringValue(POSAuditLog."Additional Information", '|', 2);
                    PPerpetualGrandTotal := GetSplitStringValue(POSAuditLog."Additional Information", '|', 3);

                    POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::ARCHIVE_CREATE);
                    POSAuditLog.FindFirst();
                    ArchiveSignature := GetAuditSignature(POSAuditLog);

                    //Filter either from last period of same type on the same POS unit or, if it's the first, from the POS Unit JET Init.
                    POSAuditLog.Reset();
                    POSAuditLog.SetRange("Acted on POS Unit No.", _POSUnitNo);
                    POSAuditLog.SetFilter("Entry No.", '<%1', _ToPOSAuditLogEntryNo);
                    POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::GRANDTOTAL);
                    POSAuditLog.SetRange("Action Custom Subtype", _PeriodType);
                    if POSAuditLog.FindLast() then begin
                        _FromPOSAuditLogEntryNo := POSAuditLog."Entry No." + 1;
                        pfromdate := Format(DT2Date(POSAuditLog.SystemCreatedAt), 0, 9);
                    end else begin
                        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::LOG_INIT);
                        POSAuditLog.SetRange("Action Custom Subtype");
                        POSAuditLog.FindLast();
                        _FromPOSAuditLogEntryNo := POSAuditLog."Entry No.";
                        pfromdate := Format(DT2Date(POSAuditLog.SystemCreatedAt), 0, 9);
                    end;
                end;

            }
        }
    }

    var
        _FromPOSAuditLogEntryNo: Integer;
        _ToPOSAuditLogEntryNo: Integer;
        _POSUnitNo: Code[10];
        _PeriodType: Text;

    local procedure GetAuditSignature(var POSAuditLog: Record "NPR POS Audit Log"): Text
    var
        InStream: InStream;
        Signature: Text;
        SignatureChunk: Text;
    begin
        POSAuditLog.CalcFields("Electronic Signature");
        POSAuditLog."Electronic Signature".CreateInStream(InStream);
        while (not InStream.EOS) do begin
            InStream.Read(SignatureChunk);
            Signature += SignatureChunk;
        end;
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