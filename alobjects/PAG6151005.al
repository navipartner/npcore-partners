page 6151005 "POS Quote Lines"
{
    // NPR5.47/MHA /20181011  CASE 302636 Object created - POS Quote (Saved POS Sale)
    // NPR5.48/MHA /20181129  CASE 336498 Added Customer info fields
    // NPR5.51/MMV /20190820  CASE 364694 Handle EFT approvals

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
                    field(POSEntrySalesTicketNo; POSQuoteEntry."Sales Ticket No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Sales Ticket No.';
                    }
                    field(POSEntryRegisterNo; POSQuoteEntry."Register No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Register No.';
                    }
                    field("POSEntrySalesperson Code"; POSQuoteEntry."Salesperson Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Salesperson Code';
                    }
                }
                group(Control6014423)
                {
                    ShowCaption = false;
                    field("POSEntryCreated at"; POSQuoteEntry."Created at")
                    {
                        ApplicationArea = All;
                        Caption = '"Created at"';
                    }
                    field(POSEntryAmount; POSQuoteEntry.Amount)
                    {
                        ApplicationArea = All;
                        Caption = 'Amount';
                    }
                    field(POSEntryAmountIncludingVAT; POSQuoteEntry."Amount Including VAT")
                    {
                        ApplicationArea = All;
                        Caption = 'Amount Including VAT';
                    }
                }
                group(Control6014419)
                {
                    ShowCaption = false;
                    field("POSQuoteEntry.""Customer Type"""; POSQuoteEntry."Customer Type")
                    {
                        ApplicationArea = All;
                        Caption = 'Customer Type';
                    }
                    field("POSQuoteEntry.""Customer No."""; POSQuoteEntry."Customer No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Customer No.';
                    }
                    field("POSQuoteEntry.""Customer Price Group"""; POSQuoteEntry."Customer Price Group")
                    {
                        ApplicationArea = All;
                        Caption = 'Customer Price Group';
                    }
                    field("POSQuoteEntry.""Customer Disc. Group"""; POSQuoteEntry."Customer Disc. Group")
                    {
                        ApplicationArea = All;
                        Caption = 'Customer Disc. Group';
                    }
                    field("POSQuoteEntry.Attention"; POSQuoteEntry.Attention)
                    {
                        ApplicationArea = All;
                        Caption = 'Attention';
                    }
                    field("POSQuoteEntry.Reference"; POSQuoteEntry.Reference)
                    {
                        ApplicationArea = All;
                        Caption = 'Reference';
                    }
                }
            }
            repeater(Group)
            {
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Price Includes VAT"; "Price Includes VAT")
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                }
                field("Discount Type"; "Discount Type")
                {
                    ApplicationArea = All;
                }
                field("Discount %"; "Discount %")
                {
                    ApplicationArea = All;
                }
                field("Discount Amount"; "Discount Amount")
                {
                    ApplicationArea = All;
                }
                field("Discount Code"; "Discount Code")
                {
                    ApplicationArea = All;
                }
                field("Discount Authorised by"; "Discount Authorised by")
                {
                    ApplicationArea = All;
                }
                field("Customer Price Group"; "Customer Price Group")
                {
                    ApplicationArea = All;
                }
                field("EFT Approved"; "EFT Approved")
                {
                    ApplicationArea = All;
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
            POSQuoteEntry.CalcFields(Amount, "Amount Including VAT");
    end;
}

