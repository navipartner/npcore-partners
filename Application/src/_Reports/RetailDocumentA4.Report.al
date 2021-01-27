report 6014486 "NPR Retail Document A4"
{
    UsageCategory = None;
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Retail Document A4.rdlc';

    Caption = 'Retail Document A4';
    UseRequestPage = true;
    UseSystemPrinter = true;

    dataset
    {
        dataitem("Retail Document Header"; "NPR Retail Document Header")
        {
            DataItemTableView = SORTING("Document Type", "No.");
            RequestFilterFields = "No.";
            RequestFilterHeading = 'Retail Document';
            column(DocumentType_RetailDocumentHeader; "Retail Document Header"."Document Type")
            {
            }
            column(No_RetailDocumentHeader; "Retail Document Header"."No.")
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(invoiceCustomer_1_RetailDocumentHeader; InvoiceCustomer[1])
            {
            }
            column(invoiceCustomer_2_RetailDocumentHeader; InvoiceCustomer[2])
            {
            }
            column(invoiceCustomer_3_RetailDocumentHeader; InvoiceCustomer[3])
            {
            }
            column(invoiceCustomer_4_RetailDocumentHeader; InvoiceCustomer[4])
            {
            }
            column(invoiceCustomer_5_RetailDocumentHeader; InvoiceCustomer[5])
            {
            }
            column(invoiceCustomer_6_RetailDocumentHeader; InvoiceCustomer[6])
            {
            }
            column(invoiceCustomer_7_RetailDocumentHeader; InvoiceCustomer[7])
            {
            }
            column(docType_RetailDocumentHeader; DocType)
            {
            }
            column(firmanavn_1_RetailDocumentHeader; Firmanavn[1])
            {
            }
            column(firmanavn_2_RetailDocumentHeader; Firmanavn[2])
            {
            }
            column(firmanavn_3_RetailDocumentHeader; Firmanavn[3])
            {
            }
            column(firmanavn_4_RetailDocumentHeader; Firmanavn[4])
            {
            }
            column(firmanavn_5_RetailDocumentHeader; Firmanavn[5])
            {
            }
            column(firmanavn_6_RetailDocumentHeader; Firmanavn[6])
            {
            }
            column(firmanavn_7_RetailDocumentHeader; Firmanavn[7])
            {
            }
            column(firmanavn_8_RetailDocumentHeader; Firmanavn[8])
            {
            }
            column(CustomerNo_RetailDocumentHeader; "Retail Document Header"."Customer No.")
            {
            }
            column(Phone_RetailDocumentHeader; "Retail Document Header".Phone)
            {
            }
            column(Mobile_RetailDocumentHeader; "Retail Document Header".Mobile)
            {
            }
            column(ShiptoAttention_RetailDocumentHeader; "Retail Document Header"."Ship-to Attention")
            {
            }
            column(salesperson_Name_RetailDocumentHeader; SalesPerson.Name)
            {
            }
            column(DocumentDate_RetailDocumentHeader; "Retail Document Header"."Document Date")
            {
            }
            column(Timeofday_RetailDocumentHeader; "Retail Document Header"."Time of Day")
            {
            }
            column(debadr_1_RetailDocumentHeader; Debadr[1])
            {
            }
            column(debadr_2_RetailDocumentHeader; Debadr[2])
            {
            }
            column(debadr_3_RetailDocumentHeader; Debadr[3])
            {
            }
            column(debadr_4_RetailDocumentHeader; Debadr[4])
            {
            }
            column(debadr_5_RetailDocumentHeader; Debadr[5])
            {
            }
            column(txtWoy_RetailDocumentHeader; TxtWoy)
            {
            }
            column(dow_RetailDocumentHeader; Dow)
            {
            }
            column(Deliverydate_RetailDocumentHeader; "Retail Document Header"."Delivery Date")
            {
            }
            column(Deliverytime1_RetailDocumentHeader; "Retail Document Header"."Delivery Time 1")
            {
            }
            column(Deliverytime2_RetailDocumentHeader; "Retail Document Header"."Delivery Time 2")
            {
            }
            column(ResourceShipbynpersons_RetailDocumentHeader; "Retail Document Header"."Resource Ship-by n Persons")
            {
            }
            column(bem_1_RetailDocumentHeader; Bem[1])
            {
            }
            column(bem_2_RetailDocumentHeader; Bem[2])
            {
            }
            column(bem_3_RetailDocumentHeader; Bem[3])
            {
            }
            column(totalAmount; TotalAmount)
            {
            }
            column(totalVAT; TotalVAT)
            {
            }
            column(totalAmountVAT; TotalAmountVAT)
            {
            }
            column(Deposit_actual; Depositactual)
            {
            }
            column(DueAmt; TotalAmountVAT - Depositactual)
            {
            }
            column(PaymentTerms_Description; PaymentTerms.Description)
            {
            }
            column(DueDate; Format("Retail Document Header"."Due Date", 0, 4))
            {
            }
            column(CurrencyCode_RetailDocumentHeader; "Retail Document Header"."Currency Code")
            {
            }
            column(txtCashed; TxtCashed)
            {
            }
            dataitem("Retail Document Lines"; "NPR Retail Document Lines")
            {
                DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                DataItemLinkReference = "Retail Document Header";
                DataItemTableView = SORTING("Document Type", "Document No.", "Line No.");
                column(No_RetailDocumentLines; "Retail Document Lines"."No.")
                {
                }
                column(LineNo_RetailDocumentLines; "Retail Document Lines"."Line No.")
                {
                }
                column(Description_RetailDocumentLines; "Retail Document Lines".Description)
                {
                }
                column(Quantity_RetailDocumentLines; "Retail Document Lines".Quantity)
                {
                }
                column(Unitprice_RetailDocumentLines; "Retail Document Lines"."Unit price")
                {
                }
                column(txtDiscountPct_RetailDocumentLines; "Line discount %")
                {
                }
                column(Amount_RetailDocumentLines; "Retail Document Lines".Amount)
                {
                }
                column(Linediscountamount_RetailDocumentLines; "Retail Document Lines"."Line discount amount")
                {
                }
                column(ReturnReasonCode_RetailDocumentLines; "Retail Document Lines"."Return Reason Code")
                {
                }
                column(ReasonCode_RetailDocumentLines; "Retail Document Lines"."Reason Code")
                {
                }
                column(DeliveryTotal_RetailDocumentLines; DeliveryTotal)
                {
                }
                column(Accessory_RetailDocumentLines; "Retail Document Lines".Accessory)
                {
                }
                column(DeliveryItem_RetailDocumentLines; "Retail Document Lines"."Delivery Item")
                {
                }
                column(ShowBody2; ShowBody2)
                {
                }
                dataitem("Retail Comment"; "NPR Retail Comment")
                {
                    DataItemTableView = SORTING("Table ID", "No.", "No. 2", Option, "Option 2", Integer, "Integer 2", "Line No.");
                    column(No_NPRComment; "Retail Comment"."No.")
                    {
                    }
                    column(Comment_NPRComment; "Retail Comment".Comment)
                    {
                    }

                    trigger OnPreDataItem()
                    begin
                        SetRange("No.", "Retail Document Header"."No.");
                        SetRange(Code, Format("Retail Document Lines"."Line No."));
                        SetRange("Hide on printout", false);
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    DeliveryItem := false;

                    if "Retail Document Lines"."Delivery Item" then begin
                        DeliveryTotal += "Retail Document Lines".Amount;
                        DeliveryItem := true;
                    end;

                    if "Retail Document Lines"."Deposit item" then begin
                        Depositactual += Amount;
                    end;

                    if "Line discount %" = 0 then
                        TxtDiscountPct := ''
                    else
                        TxtDiscountPct := Format("Line discount %") + '%';

                    ShowBody2 := false;
                    if Accessory and not DeliveryItem then
                        ShowBody2 := (Accessory and not DeliveryItem)
                    else begin
                        if (Quantity = 0) and (not NPK."Receipt - Show zero accessory") then
                            ShowBody2 := false;

                        if DeliveryItem then
                            ShowBody2 := false;
                    end;
                end;
            }
            dataitem("Integer"; "Integer")
            {
                DataItemLinkReference = "Retail Document Header";
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
            }
            dataitem(Total; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
            }
            dataitem(FooterTextbox; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
            }

            trigger OnAfterGetRecord()
            var
                Country: Record "Country/Region";
                ShipmentMethod: Record "Shipment Method";
                Retailcomments: Record "NPR Retail Comment";
                POSStore: Record "NPR POS Store";
                POSUnit: Record "NPR POS Unit";
                POSSession: Codeunit "NPR POS Session";
                POSFrontEnd: Codeunit "NPR POS Front End Management";
                POSSetup: Codeunit "NPR POS Setup";
                i: Integer;
                t001: Label 'Week';
                t002: Label 'Prices are incl. VAT';
                t003: Label 'Prices are ex. VAT';
                t004: Label 'Att.';
                t005: Label '(Cashed)';
            begin
                DocType := (Format("Retail Document Header"."Document Type"));

                DeliveryTotal := 0;
                TotalVAT := 0;

                // SHIPPING

                Debadr[1] := "Ship-to Name";
                Debadr[2] := "Ship-to Address";
                Debadr[3] := "Ship-to Address 2";
                Debadr[4] := Format("Ship-to Post Code") + ' ' + "Ship-to City";
                if "Ship-to Country Code" <> '' then begin
                    Country.Get("Ship-to Country Code");
                    Debadr[5] := "Ship-to Country Code" + '-' + Country.Name + ' [' + Country."EU Country/Region Code" + ']';
                end;
                if "Retail Document Header"."Ship-to Attention" <> '' then
                    Debadr[6] := t004 + ' ' + "Ship-to Attention";
                CompressArray(Debadr);

                // INVOICING

                InvoiceCustomer[1] := Name;
                InvoiceCustomer[2] := Address;
                InvoiceCustomer[3] := "Address 2";
                InvoiceCustomer[4] := Format("Post Code") + ' ' + City;
                if "Country Code" <> '' then begin
                    Country.Get("Country Code");
                    InvoiceCustomer[5] := "Country Code" + '-' + Country.Name + ' [' + Country."EU Country/Region Code" + ']';
                end;

                CompressArray(InvoiceCustomer);

                if "Prices Including VAT" then
                    TxtInclVAT := t002
                else
                    TxtInclVAT := t003;

                if SalesPerson.Get("Rent Salesperson") then;

                if "Delivery Date" <> 0D then begin
                    case Date2DWY("Delivery Date", 1) of
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
                    TxtWoy := t001 + ' ' + Format(Date2DWY("Retail Document Header"."Delivery Date", 2));
                end;

                if not Kasse.Get("Rent Register") then
                    Kasse.Get(RetailFormCode.FetchRegisterNumber);

                if POSSession.IsActiveSession(POSFrontEnd) then begin
                    POSFrontEnd.GetSession(POSSession);
                    POSSession.GetSetup(POSSetup);
                    POSSetup.GetPOSStore(POSStore);
                end else begin
                    if POSUnit.get(Kasse."Register No.") then
                        POSStore.get(POSUnit."POS Store Code");
                end;
                // COMPANY INFO
                Firmanavn[1] := POSStore.Name;
                Firmanavn[2] := POSStore."Name 2";
                Firmanavn[3] := POSStore.Address;
                Firmanavn[4] := Format(POSStore."Post Code") + ' ' + Format(POSStore.City);
                Firmanavn[5] := POSStore.FieldCaption("Phone No.") + ': ' + POSStore."Phone No.";
                if POSStore."Fax No." <> '' then
                    Firmanavn[6] := POSStore.FieldCaption("Fax No.") + ': ' + POSStore."Fax No.";
                Firmanavn[8] := POSStore."Home Page";
                Firmanavn[9] := POSStore."E-mail";
                Firmanavn[10] := Firmaoplysninger.FieldCaption("Bank Account No.") + ' ' + Firmaoplysninger."Bank Account No.";
                CompressArray(Firmanavn);

                if Resource.Get("Resource Ship-by Car") then;

                case Delivery of
                    Delivery::Collected:
                        begin
                            TxtDeliveryType := Format(Delivery);
                            case "Shipping Type" of
                                "Shipping Type"::"External carrier":
                                    TxtDeliveryType += ' ' + Format("Shipping Type");
                            end;
                        end;
                    Delivery::Shipped:
                        TxtDeliveryType := Format(Delivery) + ' ' + Format("Shipping Type");
                end;

                if "Payment Terms Code" <> '' then
                    PaymentTerms.Get("Payment Terms Code");

                if "Currency Code" = '' then begin
                    GLSetup.Get;
                    GLSetup.TestField("LCY Code");
                    TotalInclVATText := StrSubstNo(Text002, GLSetup."LCY Code");
                    TotalExclVATText := StrSubstNo(Text006, GLSetup."LCY Code");
                end else begin
                    TotalInclVATText := StrSubstNo(Text002, "Currency Code");
                    TotalExclVATText := StrSubstNo(Text006, "Currency Code");
                end;

                TxtShipmentCode := '';
                if ShipmentMethod.Get("Shipment Method Code") then
                    TxtShipmentCode := ShipmentMethod.Description;

                // TOTAL AMOUNT
                CalcFields(Amount);
                TotalAmount := Amount;

                // TOTAL VAT AMOUNT
                CalcFields("VAT Amount");
                TotalVAT := "VAT Amount";

                // VAT BASE AMOUNT
                CalcFields("VAT Base Amount");
                TotalVATBaseAmount := "VAT Base Amount";

                // TOTAL AMOUNT INCL. VAT
                CalcFields("Amount Incl. VAT");
                TotalAmountVAT := "Amount Incl. VAT";

                if "Delivery by Vendor" <> '' then
                    Vendor.Get("Delivery by Vendor");

                CalcFields(Comment);

                TotalPaidVAT := 0;
                TotalPaidCash := 0;
                TotalPaidDebit := 0;

                Language.SetRange("Windows Language ID", GlobalLanguage);
                if Language.FindFirst then;

                i := 1;
                Retailcomments.SetRange("No.", "Retail Document Header"."No.");
                Retailcomments.SetRange("Hide on printout", false);
                if Retailcomments.FindFirst then
                    repeat
                        Bem[i] := Retailcomments.Comment;
                        i += 1;
                    until Retailcomments.Next = 0;

                Depositactual := Deposit;

                TxtCashed := '';

                if Cashed then begin
                    Depositactual := TotalAmountVAT;
                    TxtCashed := t005;
                end;
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

    labels
    {
        Customer_Caption = 'Customer No.';
        Phone_Caption = 'Phone';
        Mobile_Caption = 'Cell No.';
        No_Caption = 'No.';
        Ship_to_Attention_Caption = 'Ship-to Attention';
        YourRef_Caption = 'Your ref.';
        Salesperson_Caption = 'Salesperson';
        DocumentDate_Caption = 'Date created';
        At_Caption = 'At';
        Delivery_Caption = 'Delivery:';
        Date_Caption = 'Date';
        Person_Caption = '# Persons';
        Comment_Caption = 'Comment';
        DeliveryTime1_Caption = 'Delivery time 1';
        DeliveryTime2_Caption = 'Delivery time 2';
        ItemNo_Caption = 'Item No.';
        Description_Caption = 'Description';
        Quantity_Caption = 'Quantity';
        UnitPrice_Caption = 'Unit Price';
        Amount_Caption = 'Amount';
        ReturnReasonCode_Caption = 'Return Reason Code';
        ReasonCode_Caption = 'Reason Code';
        DeliveryCost_Caption = 'Delivery cost';
        PaymentTerms_Caption = 'Payment terms';
        LastDayOfPayment_Capttion = 'Last Day of Payment';
        Total_Caption = 'Total';
        VATAmt_Caption = 'VAT Amount';
        IncVAT_Caption = 'Inc. VAT ';
        Paid_Caption = 'Paid';
        DueAmt_Caption = 'Due amount';
        HavingReceivedIntact_Caption = 'Having received intact items';
        HavingReceived_Caption = 'Having received above remaining amount';
        Footer1_Caption = 'ATT! New products have 24 mon. warranty. Get an 5 year total insurrance offer in the shop. ';
        Footer2_Caption = 'Attention is drawn to the fact that interest at a rate of 1.5 per cent per commenced month will be charged on overdue accounts.';
        Footer3_Caption = 'Installation of new products only at legal installations. Materials not included.';
        Page_Caption = 'Page';
    }

    trigger OnPreReport()
    begin
        if NPK.Get then;
        Udbetaling_check := false;
        Firmaoplysninger.Get;
        Firmaoplysninger.CalcFields(Picture);
    end;

    var
        Udbetaling_check: Boolean;
        DeliveryItem: Boolean;
        RetailFormCode: Codeunit "NPR Retail Form Code";
        Depositactual: Decimal;
        TotalVAT: Decimal;
        DeliveryTotal: Decimal;
        TotalAmount: Decimal;
        TotalAmountVAT: Decimal;
        TotalVATBaseAmount: Decimal;
        TotalPaidVAT: Decimal;
        TotalPaidCash: Decimal;
        TotalPaidDebit: Decimal;
        NPK: Record "NPR Retail Setup";
        Kasse: Record "NPR Register";
        SalesPerson: Record "Salesperson/Purchaser";
        Firmaoplysninger: Record "Company Information";
        Resource: Record Resource;
        PaymentTerms: Record "Payment Terms";
        GLSetup: Record "General Ledger Setup";
        Vendor: Record Vendor;
        Language: Record Language;
        TotalInclVATText: Text[30];
        TotalExclVATText: Text[30];
        InvoiceCustomer: array[8] of Text[30];
        TxtShipmentCode: Text[100];
        TxtInclVAT: Text[100];
        DocType: Text[50];
        TxtDiscountPct: Text[30];
        Firmanavn: array[10] of Text[30];
        Debadr: array[8] of Text[30];
        Dow: Text[10];
        TxtWoy: Text[30];
        TxtDeliveryType: Text[50];
        Bem: array[10] of Text[50];
        TxtCashed: Text[30];
        MonTXT: Label 'Monday';
        TueTXT: Label 'Tuesday';
        WedTXT: Label 'Wednesday';
        ThuTXT: Label 'Thursday';
        FriTXT: Label 'Friday';
        SatTXT: Label 'Saturday';
        SunTXT: Label 'Saturday';
        Text002: Label 'Total %1 Incl. VAT';
        Text006: Label 'Total %1 Excl. VAT';
        ShowBody2: Boolean;
}

