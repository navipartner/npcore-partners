page 6151005 "NPR POS Saved Sale Lines"
{
    Caption = 'POS Saved Sale Lines';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Saved Sale Line";

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
                        ToolTip = 'Specifies the value of the Sales Ticket No. field';
                    }
                    field(POSEntryRegisterNo; POSQuoteEntry."Register No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Register No.';
                        ToolTip = 'Specifies the value of the Register No. field';
                    }
                    field("POSEntrySalesperson Code"; POSQuoteEntry."Salesperson Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Salesperson Code';
                        ToolTip = 'Specifies the value of the Salesperson Code field';
                    }
                }
                group(Control6014423)
                {
                    ShowCaption = false;
                    field("POSEntryCreated at"; POSQuoteEntry."Created at")
                    {
                        ApplicationArea = All;
                        Caption = '"Created at"';
                        ToolTip = 'Specifies the value of the "Created at" field';
                    }
                    field(POSEntryAmount; POSQuoteEntry.Amount)
                    {
                        ApplicationArea = All;
                        Caption = 'Amount';
                        ToolTip = 'Specifies the value of the Amount field';
                    }
                    field(POSEntryAmountIncludingVAT; POSQuoteEntry."Amount Including VAT")
                    {
                        ApplicationArea = All;
                        Caption = 'Amount Including VAT';
                        ToolTip = 'Specifies the value of the Amount Including VAT field';
                    }
                }
                group(Control6014419)
                {
                    ShowCaption = false;
                    field("POSQuoteEntry.""Customer Type"""; POSQuoteEntry."Customer Type")
                    {
                        ApplicationArea = All;
                        Caption = 'Customer Type';
                        ToolTip = 'Specifies the value of the Customer Type field';
                    }
                    field("POSQuoteEntry.""Customer No."""; POSQuoteEntry."Customer No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Customer No.';
                        ToolTip = 'Specifies the value of the Customer No. field';
                    }
                    field("POSQuoteEntry.""Customer Price Group"""; POSQuoteEntry."Customer Price Group")
                    {
                        ApplicationArea = All;
                        Caption = 'Customer Price Group';
                        ToolTip = 'Specifies the value of the Customer Price Group field';
                    }
                    field("POSQuoteEntry.""Customer Disc. Group"""; POSQuoteEntry."Customer Disc. Group")
                    {
                        ApplicationArea = All;
                        Caption = 'Customer Disc. Group';
                        ToolTip = 'Specifies the value of the Customer Disc. Group field';
                    }
                    field("POSQuoteEntry.Attention"; POSQuoteEntry.Attention)
                    {
                        ApplicationArea = All;
                        Caption = 'Attention';
                        ToolTip = 'Specifies the value of the Attention field';
                    }
                    field("POSQuoteEntry.Reference"; POSQuoteEntry.Reference)
                    {
                        ApplicationArea = All;
                        Caption = 'Reference';
                        ToolTip = 'Specifies the value of the Reference field';
                    }
                }
            }
            repeater(Group)
            {
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Including VAT field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description 2 field';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit of Measure Code field';
                }
                field("Price Includes VAT"; Rec."Price Includes VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Price Includes VAT field';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field("Discount Type"; Rec."Discount Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Type field';
                }
                field("Discount %"; Rec."Discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount % field';
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount field';
                }
                field("Discount Code"; Rec."Discount Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Code field';
                }
                field("Discount Authorised by"; Rec."Discount Authorised by")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Authorised by field';
                }
                field("Customer Price Group"; Rec."Customer Price Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Price Group field';
                }
                field("EFT Approved"; Rec."EFT Approved")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Electronic Funds Transfer Approved field';
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
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";

    local procedure FindPOSEntry()
    var
        EntryNo: BigInteger;
    begin
        Clear(POSQuoteEntry);

        EntryNo := Rec."Quote Entry No.";
        if EntryNo = 0 then begin
            if Rec.GetFilter("Quote Entry No.") = '' then
                exit;

            EntryNo := Rec.GetRangeMax("Quote Entry No.");
        end;


        if POSQuoteEntry.Get(EntryNo) then
            POSQuoteEntry.CalcFields(Amount, "Amount Including VAT");
    end;
}
