xmlport 6150901 "NPR HC POS Entry"
{
    // NPR5.38/BR  /20171030  CASE 295007  Object Created
    // NPR5.39/BR  /20180212  CASE 295007  Updated fields, Filled External Source No.'s

    Caption = 'HC POS Entry';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(postransaction)
        {
            MaxOccurs = Once;
            textelement(insertposentryline)
            {
                MaxOccurs = Once;
                tableelement(posentry; "NPR POS Entry")
                {
                    XmlName = 'posentry';
                    UseTemporary = true;
                    fieldelement(sourcename; POSEntry."External Source Name")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(entryno; POSEntry."Entry No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(posstorecode; POSEntry."POS Store Code")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(posunitno; POSEntry."POS Unit No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(posdocumentno; POSEntry."Document No.")
                    {
                        MinOccurs = Zero;
                    }
                    tableelement(posledgerregister; "NPR POS Period Register")
                    {
                        LinkTable = POSEntry;
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        XmlName = 'posledgerregister';
                        SourceTableView = SORTING("No.");
                        UseTemporary = true;
                        fieldelement(posledgerregisterno; POSLedgerRegister."No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(posledgerregisterdocno; POSLedgerRegister."Document No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(noseries; POSLedgerRegister."No. Series")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(openingentryno; POSLedgerRegister."Opening Entry No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(closingentryno; POSLedgerRegister."Closing Entry No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(posledgerregisterstatus; POSLedgerRegister.Status)
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(pospostingcompression; POSLedgerRegister."Posting Compression")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(openeddate; POSLedgerRegister."Opened Date")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(endofdaydate; POSLedgerRegister."End of Day Date")
                        {
                            MinOccurs = Zero;
                        }
                    }
                    fieldelement(entrytype; POSEntry."Entry Type")
                    {
                    }
                    fieldelement(entrydate; POSEntry."Entry Date")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(startingtime; POSEntry."Starting Time")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(endingtime; POSEntry."Ending Time")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(description; POSEntry.Description)
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(customerno; POSEntry."Customer No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(systementry; POSEntry."System Entry")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(shortcutdimension1code; POSEntry."Shortcut Dimension 1 Code")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(shortcutdomension2code; POSEntry."Shortcut Dimension 2 Code")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(salespersoncode; POSEntry."Salesperson Code")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(noprinted; POSEntry."No. Printed")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(postitementrystatus; POSEntry."Post Item Entry Status")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(postentrystatus; POSEntry."Post Entry Status")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(postingdate; POSEntry."Posting Date")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(documentdate; POSEntry."Document Date")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(currencycode; POSEntry."Currency Code")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(currencyfactor; POSEntry."Currency Factor")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(salesamount; POSEntry."Item Sales (LCY)")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(discountamount; POSEntry."Discount Amount")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(salesquantity; POSEntry."Sales Quantity")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(returnsalesquantity; POSEntry."Return Sales Quantity")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(totalamount; POSEntry."Amount Excl. Tax")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(totaltaxamount; POSEntry."Tax Amount")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(totalamountincltax; POSEntry."Amount Incl. Tax")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(roundingamountLCY; POSEntry."Rounding Amount (LCY)")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(taxareacode; POSEntry."Tax Area Code")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(possaleid; POSEntry."POS Sale ID")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(customerpostinggroup; POSEntry."Customer Posting Group")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(countryregioncode; POSEntry."Country/Region Code")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(transactiontype; POSEntry."Transaction Type")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(transportmethod; POSEntry."Transport Method")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(exitpoint; POSEntry."Exit Point")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement("area"; POSEntry."Area")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(transactionscpecification; POSEntry."Transaction Specification")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(pricesincludevat; POSEntry."Prices Including VAT")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(reasoncode; POSEntry."Reason Code")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(dimensionsetid; POSEntry."Dimension Set ID")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(salesdocumenttype; POSEntry."Sales Document Type")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(salesdocumentno; POSEntry."Sales Document No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(contactno; POSEntry."Contact No.")
                    {
                        MinOccurs = Zero;
                    }
                    tableelement(posentrydimension; "Dimension ID Buffer")
                    {
                        LinkTable = POSEntry;
                        MinOccurs = Zero;
                        XmlName = 'posentrydimension';
                        UseTemporary = true;
                        fieldelement(dimensioncode; posentrydimension."Dimension Code")
                        {
                        }
                        fieldelement(dimensionvalue; posentrydimension."Dimension Value")
                        {
                        }
                    }
                    tableelement(possalesline; "NPR POS Sales Line")
                    {
                        LinkTable = POSEntry;
                        MinOccurs = Zero;
                        XmlName = 'possalesline';
                        SourceTableView = SORTING("POS Entry No.", "Line No.");
                        UseTemporary = true;
                        fieldelement(lineno; possalesline."Line No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(type; possalesline.Type)
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(no; possalesline."No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(locationcode; possalesline."Location Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(postinggroup; possalesline."Posting Group")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(description; possalesline.Description)
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(quantity; possalesline.Quantity)
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(customerno; possalesline."Customer No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(unitprice; possalesline."Unit Price")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(unitcostlcy; possalesline."Unit Cost (LCY)")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(vatperc; possalesline."VAT %")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(linediscountperc; possalesline."Line Discount %")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(linediscountamountexclvat; possalesline."Line Discount Amount Excl. VAT")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(linediscountamountinclvat; possalesline."Line Discount Amount Incl. VAT")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(amountexclvat; possalesline."Amount Excl. VAT")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(amountinclvat; possalesline."Amount Incl. VAT")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(linediscamountexclvatlcy; possalesline."Line Dsc. Amt. Excl. VAT (LCY)")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(linediscamountinclvatlcy; possalesline."Line Dsc. Amt. Incl. VAT (LCY)")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(amountexclvatlcy; possalesline."Amount Excl. VAT (LCY)")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(amountinclvatlcy; possalesline."Amount Incl. VAT (LCY)")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(applytoentryno; possalesline."Appl.-to Item Entry")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(itementryno; possalesline."Item Entry No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(shortcutdimension1; possalesline."Shortcut Dimension 1 Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(shortcutdimension2; possalesline."Shortcut Dimension 2 Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(salespersoncode; possalesline."Salesperson Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(witholditem; possalesline."Withhold Item")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(movetolocation; possalesline."Move to Location")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(currencycode; possalesline."Currency Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(genbuspostinggroup; possalesline."Gen. Bus. Posting Group")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(genprodpostinggroup; possalesline."Gen. Prod. Posting Group")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(vatcalculationtype; possalesline."VAT Calculation Type")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(genpostingtype; possalesline."Gen. Posting Type")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(taxareacode; possalesline."Tax Area Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(taxliable; possalesline."Tax Liable")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(taxgroupcode; possalesline."Tax Group Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(usetax; possalesline."Use Tax")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(vatbuspostinggroup; possalesline."VAT Bus. Posting Group")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(vatprodpostinggroup; possalesline."VAT Prod. Posting Group")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(vatbaseamount; possalesline."VAT Base Amount")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(unitcost; possalesline."Unit Cost")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(vatdifference; possalesline."VAT Difference")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(vatidentifier; possalesline."VAT Identifier")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(salesdocumenttype; possalesline."Sales Document Type")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(salesdocumentno; possalesline."Sales Document No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(salesdocumentline; possalesline."Sales Document Line No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(origpossaleid; possalesline."Orig. POS Sale ID")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(origposlineno; possalesline."Orig. POS Line No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(bincode; possalesline."Bin Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(qtyerunitofmeasure; possalesline."Qty. per Unit of Measure")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(crossreferenceno; possalesline."Cross-Reference No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(origninallyorderedno; possalesline."Originally Ordered No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(origninallyorderedvariantcode; possalesline."Originally Ordered Var. Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(outofstocksubstitute; possalesline."Out-of-Stock Substitution")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(purchasingcode; possalesline."Purchasing Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(productgroupcode; possalesline."Product Group Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(planneddeliverydate; possalesline."Planned Delivery Date")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(reasoncode; possalesline."Reason Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(discounttype; possalesline."Discount Type")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(discountcode; possalesline."Discount Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(dimensionsetid; possalesline."Dimension Set ID")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(variantcode; possalesline."Variant Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(unitofmeasurecode; possalesline."Unit of Measure Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(quantitybase; possalesline."Quantity (Base)")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(itemcategorycode; possalesline."Item Category Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(nonstock; possalesline.Nonstock)
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(bomitemno; possalesline."BOM Item No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(serailno; possalesline."Serial No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(lotno; possalesline."Lot No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(returnreasoncode; possalesline."Return Reason Code")
                        {
                            MinOccurs = Zero;
                        }
                        tableelement(possaleslinedimension; "Dimension ID Buffer")
                        {
                            LinkTable = possalesline;
                            XmlName = 'possaleslinedimension';
                            UseTemporary = true;
                            fieldelement(dimensioncode; possaleslinedimension."Dimension Code")
                            {
                            }
                            fieldelement(dimensionvalue; possaleslinedimension."Dimension Value")
                            {
                            }
                        }
                    }
                    tableelement(pospaymentline; "NPR POS Payment Line")
                    {
                        LinkTable = POSEntry;
                        MinOccurs = Zero;
                        XmlName = 'pospaymentline';
                        UseTemporary = true;
                        fieldelement(lineno; pospaymentline."Line No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(pospaymentmethodcode; pospaymentline."POS Payment Method Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(pospaymentbincode; pospaymentline."POS Payment Bin Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(description; pospaymentline.Description)
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(amount; pospaymentline.Amount)
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(paymentfeeperc; pospaymentline."Payment Fee %")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(paymentfeeamount; pospaymentline."Payment Fee Amount")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(paymentamount; pospaymentline."Payment Amount")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(paymentfeepercnoninvoiced; pospaymentline."Payment Fee % (Non-invoiced)")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(paymentfeeamountnoninvoiced; pospaymentline."Payment Fee Amount (Non-inv.)")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(currencycode; pospaymentline."Currency Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(shortcutdimension1code; pospaymentline."Shortcut Dimension 1 Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(shortcutdimension2code; pospaymentline."Shortcut Dimension 2 Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(amountlcy; pospaymentline."Amount (LCY)")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(amoundsalescurrency; pospaymentline."Amount (Sales Currency)")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(roundingamount; pospaymentline."Rounding Amount")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(roundingamountsalescurr; pospaymentline."Rounding Amount (Sales Curr.)")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(roundingamountlcy; pospaymentline."Rounding Amount (LCY)")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(appliestodoctype; pospaymentline."Applies-to Doc. Type")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(appliestodocno; pospaymentline."Applies-to Doc. No.")
                        {
                        }
                        fieldelement(externaldocno; pospaymentline."External Document No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(origpossaleid; pospaymentline."Orig. POS Sale ID")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(origposlineno; pospaymentline."Orig. POS Line No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(dimensionsetid; pospaymentline."Dimension Set ID")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(eft; pospaymentline.EFT)
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(eftrefundable; pospaymentline."EFT Refundable")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(token; pospaymentline.Token)
                        {
                            MinOccurs = Zero;
                        }
                        tableelement(pospaymentlinedimension; "Dimension ID Buffer")
                        {
                            LinkTable = possalesline;
                            MinOccurs = Zero;
                            XmlName = 'pospaymentlinedimension';
                            UseTemporary = true;
                            fieldelement(dimensioncode; pospaymentlinedimension."Dimension Code")
                            {
                            }
                            fieldelement(dimensionvalue; pospaymentlinedimension."Dimension Value")
                            {
                            }
                        }
                    }
                    tableelement(postaxamountline; "NPR POS Tax Amount Line")
                    {
                        LinkTable = POSEntry;
                        MinOccurs = Zero;
                        XmlName = 'postaxamountline';
                        UseTemporary = true;
                        fieldelement(lineno; postaxamountline."Tax Area Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(taxjurisdictioncode; postaxamountline."Tax Jurisdiction Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(vatidentifier; postaxamountline."VAT Identifier")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(taxcalculationtype; postaxamountline."Tax Calculation Type")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(taxgroupcode; postaxamountline."Tax Group Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(quantity; postaxamountline.Quantity)
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(modified; postaxamountline.Modified)
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(usetax; postaxamountline."Use Tax")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(calculatedtaxamount; postaxamountline."Calculated Tax Amount")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(taxdifference; postaxamountline."Tax Difference")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(taxtype; postaxamountline."Tax Type")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(taxliable; postaxamountline."Tax Liable")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(taxareacodeforkey; postaxamountline."Tax Area Code for Key")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(invoicediscountamount; postaxamountline."Invoice Discount Amount")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(invdiscbaseamount; postaxamountline."Inv. Disc. Base Amount")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(taxperc; postaxamountline."Tax %")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(taxbaseamount; postaxamountline."Tax Base Amount")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(taxamount; postaxamountline."Tax Amount")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(amountincludingtax; postaxamountline."Amount Including Tax")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(lineamount; postaxamountline."Line Amount")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(expensecapitalize; postaxamountline."Expense/Capitalize")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(printorder; postaxamountline."Print Order")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(printdescription; postaxamountline."Print Description")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(calcluationorder; postaxamountline."Calculation Order")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(roundtax; postaxamountline."Round Tax")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(isreporttojurisdiction; postaxamountline."Is Report-to Jurisdiction")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(positive; postaxamountline.Positive)
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(taxbaseamountfcy; postaxamountline."Tax Base Amount FCY")
                        {
                            MinOccurs = Zero;
                        }
                    }
                    tableelement(posbalancingline; "NPR POS Balancing Line")
                    {
                        LinkTable = POSEntry;
                        MinOccurs = Zero;
                        XmlName = 'posbalancingline';
                        UseTemporary = true;
                        fieldelement(lineno; posbalancingline."Line No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(pospaymentbincode; posbalancingline."POS Payment Bin Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(pospaymentmethodcode; posbalancingline."POS Payment Method Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(calculatedamount; posbalancingline."Calculated Amount")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(balancedamount; posbalancingline."Balanced Amount")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(balanceddiffamount; posbalancingline."Balanced Diff. Amount")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(newfloatamount; posbalancingline."New Float Amount")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(shortcuddimension1code; posbalancingline."Shortcut Dimension 1 Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(shortcutdimension2code; posbalancingline."Shortcut Dimension 2 Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(calculatedquantity; posbalancingline."Calculated Quantity")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(balancedquantity; posbalancingline."Balanced Quantity")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(balanceddiffquantity; posbalancingline."Balanced Diff. Quantity")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(depositedquantity; posbalancingline."Deposited Quantity")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(closingquantity; posbalancingline."Closing Quantity")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(description; posbalancingline.Description)
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(deposittobinamount; posbalancingline."Deposit-To Bin Amount")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(deposittobincode; posbalancingline."Deposit-To Bin Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(deposittoreference; posbalancingline."Deposit-To Reference")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(movetobinamount; posbalancingline."Move-To Bin Amount")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(movetobincode; posbalancingline."Move-To Bin Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(movetoreference; posbalancingline."Move-To Reference")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(balancingdetails; posbalancingline."Balancing Details")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(origpossaleid; posbalancingline."Orig. POS Sale ID")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(origposlineno; posbalancingline."Orig. POS Line No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(posbincheckpointentryno; posbalancingline."POS Bin Checkpoint Entry No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(currencycode; posbalancingline."Currency Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(dimensionsetid; posbalancingline."Dimension Set ID")
                        {
                            MinOccurs = Zero;
                        }
                        tableelement(posbalancinglinedimension; "Dimension ID Buffer")
                        {
                            LinkTable = possalesline;
                            MinOccurs = Zero;
                            XmlName = 'posbalancinglinedimension';
                            UseTemporary = true;
                            fieldelement(dimensioncode; posbalancinglinedimension."Dimension Code")
                            {
                            }
                            fieldelement(dimensionvalue; posbalancinglinedimension."Dimension Value")
                            {
                            }
                        }
                    }
                }
            }
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
}

