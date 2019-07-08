xmlport 6150900 "HC Audit Roll"
{
    // NPR5.37/BR  /20171027 CASE 267552 HQ Connector Created Object
    // NPR5.39/BR  /20180221 CASE 225415 Renumberd fields in 5xxxx range
    // NPR5.44/MHA /20180704  CASE 318391 Added attribute @direct_posting
    // NPR5.48/MHA /20181121 CASE 326055 Added field reference

    Caption = 'HC Audit Roll';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(auditroll)
        {
            textelement(insertauditrollline)
            {
                MinOccurs = Zero;
                textattribute(direct_posting)
                {
                    Occurrence = Optional;
                }
                tableelement(tempbcauditroll;"HC Audit Roll")
                {
                    MinOccurs = Zero;
                    XmlName = 'auditrollline';
                    UseTemporary = true;
                    fieldelement(registerno;TempBCAuditRoll."Register No.")
                    {
                    }
                    fieldelement(salesticketno;TempBCAuditRoll."Sales Ticket No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(saletype;TempBCAuditRoll."Sale Type")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(lineno;TempBCAuditRoll."Line No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(type;TempBCAuditRoll.Type)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(no;TempBCAuditRoll."No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(lokationskode;TempBCAuditRoll.Lokationskode)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(description;TempBCAuditRoll.Description)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(unit;TempBCAuditRoll.Unit)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(quantity;TempBCAuditRoll.Quantity)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(vatperc;TempBCAuditRoll."VAT %")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(linediscountperc;TempBCAuditRoll."Line Discount %")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(linediscountamount;TempBCAuditRoll."Line Discount Amount")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(saledate;TempBCAuditRoll."Sale Date")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(posteddocno;TempBCAuditRoll."Posted Doc. No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(amount;TempBCAuditRoll.Amount)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(amountinclvat;TempBCAuditRoll."Amount Including VAT")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(departmentcode;TempBCAuditRoll."Department Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(serialno;TempBCAuditRoll."Serial No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(customeritemdiscount;TempBCAuditRoll."Customer/Item Discount %")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(genbuspostinggroup;TempBCAuditRoll."Gen. Bus. Posting Group")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(genprodpostinggroup;TempBCAuditRoll."Gen. Prod. Posting Group")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(vatbuspostinggroup;TempBCAuditRoll."VAT Bus. Posting Group")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(vatprodpostinggroup;TempBCAuditRoll."VAT Prod. Posting Group")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(currencycode;TempBCAuditRoll."Currency Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(cost;TempBCAuditRoll.Cost)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(giftvoucherref;TempBCAuditRoll."Gift voucher ref.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(creditvoucherref;TempBCAuditRoll."Credit voucher ref.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(shortcutdimension1;TempBCAuditRoll."Shortcut Dimension 1 Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(shortcutdimension2;TempBCAuditRoll."Shortcut Dimension 2 Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(bincode;TempBCAuditRoll."Bin Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(taxareacode;TempBCAuditRoll."Tax Area Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(taxliable;TempBCAuditRoll."Tax Liable")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(taxgroupcode;TempBCAuditRoll."Tax Group Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(usetax;TempBCAuditRoll."Use Tax")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(returnreasoncode;TempBCAuditRoll."Return Reason Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(clusteredkey;TempBCAuditRoll."Clustered Key")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(unitcost;TempBCAuditRoll."Unit Cost")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(systemcreatedentry;TempBCAuditRoll."System-Created Entry")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(variantcode;TempBCAuditRoll."Variant Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(allocatedno;TempBCAuditRoll."Allocated No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(documenttype;TempBCAuditRoll."Document Type")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(retaildocumenttype;TempBCAuditRoll."Retail Document Type")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(retaildocumentno;TempBCAuditRoll."Retail Document No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(salesdocumenttype;TempBCAuditRoll."Sales Document Type")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(salesdocumentno;TempBCAuditRoll."Sales Document No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(salesdocumentprepayment;TempBCAuditRoll."Sales Document Prepayment")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(salesdocprepaymentperc;TempBCAuditRoll."Sales Doc. Prepayment %")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(salesdocumentinvoice;TempBCAuditRoll."Sales Document Invoice")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(salesdocumentship;TempBCAuditRoll."Sales Document Ship")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(possaleid;TempBCAuditRoll."POS Sale ID")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(salespersoncode;TempBCAuditRoll."Salesperson Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(discounttype;TempBCAuditRoll."Discount Type")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(dimensionsetid;TempBCAuditRoll."Dimension Set ID")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(cashterminalapproved;TempBCAuditRoll."Cash Terminal Approved")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(draweropened;TempBCAuditRoll."Drawer Opened")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(startingtime;TempBCAuditRoll."Starting Time")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(closingtime;TempBCAuditRoll."Closing Time")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(receipttype;TempBCAuditRoll."Receipt Type")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(closingcash;TempBCAuditRoll."Closing Cash")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(openingcash;TempBCAuditRoll."Opening Cash")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(transferredtobalanceaccount;TempBCAuditRoll."Transferred to Balance Account")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(difference;TempBCAuditRoll.Difference)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(changeregister;TempBCAuditRoll."Change Register")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(posted;TempBCAuditRoll.Posted)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(postingdate;TempBCAuditRoll."Posting Date")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(internalpostingno;TempBCAuditRoll."Internal Posting No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(color;TempBCAuditRoll.Color)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(size;TempBCAuditRoll.Size)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(serialnonotcreated;TempBCAuditRoll."Serial No. not Created")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(customerno;TempBCAuditRoll."Customer No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(customertype;TempBCAuditRoll."Customer Type")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(paymenttypeno;TempBCAuditRoll."Payment Type No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(n3debitsaleconversion;TempBCAuditRoll."N3 Debit Sale Conversion")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(bufferdocumenttype;TempBCAuditRoll."Buffer Document Type")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(bufferid;TempBCAuditRoll."Buffer ID")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(bufferinvoiceno;TempBCAuditRoll."Buffer Invoice No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(reasoncode;TempBCAuditRoll."Reason Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(description2;TempBCAuditRoll."Description 2")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(moneybagno;TempBCAuditRoll."Money bag no.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(externaldocumentno;TempBCAuditRoll."External Document No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(linecounter;TempBCAuditRoll.LineCounter)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(balancing;TempBCAuditRoll.Balancing)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(vendor;TempBCAuditRoll.Vendor)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(invoizguid;TempBCAuditRoll."Invoiz Guid")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(noprinted;TempBCAuditRoll."No. Printed")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(offline;TempBCAuditRoll.Offline)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(customerpostcode;TempBCAuditRoll."Customer Post Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(currencyamount;TempBCAuditRoll."Currency Amount")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(itementryposted;TempBCAuditRoll."Item Entry Posted")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(send;TempBCAuditRoll.Send)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(offlinereceiptno;TempBCAuditRoll."Offline receipt no.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(reference;TempBCAuditRoll.Reference)
                    {
                        MinOccurs = Zero;
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

    procedure GetSalesTicketNo(): Text
    begin
        //-NPR5.44 [318391]
        exit(TempBCAuditRoll."Sales Ticket No.");
        //+NPR5.44 [318391]
    end;
}

