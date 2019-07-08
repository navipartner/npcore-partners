page 6151005 "POS Quote Lines"
{
    // NPR5.47/MHA /20181011  CASE 302636 Object created - POS Quote (Saved POS Sale)
    // NPR5.48/MHA /20181129  CASE 336498 Added Customer info fields

    Caption = 'POS Quote Lines';
    Editable = false;
    PageType = Worksheet;
    SourceTable = "POS Quote Line";

    layout
    {
        area(content)
        {
            grid(General)
            {
                Caption = 'General';
                group(Control6014418)
                {
                    ShowCaption = false;
                    field(POSEntrySalesTicketNo;POSQuoteEntry."Sales Ticket No.")
                    {
                        Caption = 'Sales Ticket No.';
                    }
                    field(POSEntryRegisterNo;POSQuoteEntry."Register No.")
                    {
                        Caption = 'Register No.';
                    }
                    field("POSEntrySalesperson Code";POSQuoteEntry."Salesperson Code")
                    {
                        Caption = 'Salesperson Code';
                    }
                }
                group(Control6014423)
                {
                    ShowCaption = false;
                    field("POSEntryCreated at";POSQuoteEntry."Created at")
                    {
                        Caption = '"Created at"';
                    }
                    field(POSEntryAmount;POSQuoteEntry.Amount)
                    {
                        Caption = 'Amount';
                    }
                    field(POSEntryAmountIncludingVAT;POSQuoteEntry."Amount Including VAT")
                    {
                        Caption = 'Amount Including VAT';
                    }
                }
                group(Control6014419)
                {
                    ShowCaption = false;
                    field("POSQuoteEntry.""Customer Type""";POSQuoteEntry."Customer Type")
                    {
                        Caption = 'Customer Type';
                    }
                    field("POSQuoteEntry.""Customer No.""";POSQuoteEntry."Customer No.")
                    {
                        Caption = 'Customer No.';
                    }
                    field("POSQuoteEntry.""Customer Price Group""";POSQuoteEntry."Customer Price Group")
                    {
                        Caption = 'Customer Price Group';
                    }
                    field("POSQuoteEntry.""Customer Disc. Group""";POSQuoteEntry."Customer Disc. Group")
                    {
                        Caption = 'Customer Disc. Group';
                    }
                    field("POSQuoteEntry.Attention";POSQuoteEntry.Attention)
                    {
                        Caption = 'Attention';
                    }
                    field("POSQuoteEntry.Reference";POSQuoteEntry.Reference)
                    {
                        Caption = 'Reference';
                    }
                }
            }
            repeater(Group)
            {
                field(Description;Description)
                {
                }
                field(Quantity;Quantity)
                {
                }
                field("Unit Price";"Unit Price")
                {
                }
                field("Amount Including VAT";"Amount Including VAT")
                {
                }
                field(Type;Type)
                {
                }
                field("No.";"No.")
                {
                }
                field("Variant Code";"Variant Code")
                {
                }
                field("Description 2";"Description 2")
                {
                }
                field("Unit of Measure Code";"Unit of Measure Code")
                {
                }
                field("Price Includes VAT";"Price Includes VAT")
                {
                }
                field(Amount;Amount)
                {
                }
                field("Currency Code";"Currency Code")
                {
                }
                field("Discount Type";"Discount Type")
                {
                }
                field("Discount %";"Discount %")
                {
                }
                field("Discount Amount";"Discount Amount")
                {
                }
                field("Discount Code";"Discount Code")
                {
                }
                field("Discount Authorised by";"Discount Authorised by")
                {
                }
                field("Customer Price Group";"Customer Price Group")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        FindPOSEntry();
    end;

    trigger OnOpenPage()
    begin
        FindPOSEntry();
    end;

    var
        POSQuoteEntry: Record "POS Quote Entry";

    local procedure FindPOSEntry()
    var
        EntryNo: BigInteger;
    begin
        Clear(POSQuoteEntry);

        EntryNo := "Quote Entry No.";
        if EntryNo = 0 then begin
          if GetFilter("Quote Entry No.") = '' then
            exit;

          EntryNo := GetRangeMax("Quote Entry No.");
        end;


        if POSQuoteEntry.Get(EntryNo) then
          POSQuoteEntry.CalcFields(Amount,"Amount Including VAT");
    end;
}

