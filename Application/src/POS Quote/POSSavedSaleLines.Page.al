page 6151005 "NPR POS Saved Sale Lines"
{
    Extensible = False;
    Caption = 'POS Saved Sale Lines';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR POS Saved Sale Line";
    ApplicationArea = NPRRetail;

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
                    field("Sales Ticket No"; POSQuoteEntry."Sales Ticket No.")
                    {

                        Caption = 'Sales Ticket No.';
                        ToolTip = 'Specifies the value of the Sales Ticket No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Register No"; POSQuoteEntry."Register No.")
                    {

                        Caption = 'Register No.';
                        ToolTip = 'Specifies the value of the Register No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Salesperson Code"; POSQuoteEntry."Salesperson Code")
                    {

                        Caption = 'Salesperson Code';
                        ToolTip = 'Specifies the value of the Salesperson Code field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014423)
                {
                    ShowCaption = false;
                    field("Created at"; POSQuoteEntry."Created at")
                    {

                        Caption = '"Created at"';
                        ToolTip = 'Specifies the value of the "Created at" field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Amount; POSQuoteEntry.Amount)
                    {

                        Caption = 'Amount';
                        ToolTip = 'Specifies the value of the Amount field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Amount Including VAT"; POSQuoteEntry."Amount Including VAT")
                    {

                        Caption = 'Amount Including VAT';
                        ToolTip = 'Specifies the value of the Amount Including VAT field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014419)
                {
                    ShowCaption = false;
                    field("Customer Type"; POSQuoteEntry."Customer Type")
                    {

                        Caption = 'Customer Type';
                        ToolTip = 'Specifies the value of the Customer Type field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Customer No."; POSQuoteEntry."Customer No.")
                    {

                        Caption = 'Customer No.';
                        ToolTip = 'Specifies the value of the Customer No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Customer Price Group"; POSQuoteEntry."Customer Price Group")
                    {

                        Caption = 'Customer Price Group';
                        ToolTip = 'Specifies the value of the Customer Price Group field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Customer Discount Group"; POSQuoteEntry."Customer Disc. Group")
                    {

                        Caption = 'Customer Disc. Group';
                        ToolTip = 'Specifies the value of the Customer Disc. Group field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Attention; POSQuoteEntry.Attention)
                    {

                        Caption = 'Attention';
                        ToolTip = 'Specifies the value of the Attention field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Reference; POSQuoteEntry.Reference)
                    {

                        Caption = 'Reference';
                        ToolTip = 'Specifies the value of the Reference field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            repeater(Group)
            {
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {

                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price"; Rec."Unit Price")
                {

                    ToolTip = 'Specifies the value of the Unit Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Incl. VAT"; Rec."Amount Including VAT")
                {

                    ToolTip = 'Specifies the value of the Amount Including VAT field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Description 2"; Rec."Description 2")
                {

                    ToolTip = 'Specifies the value of the Description 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {

                    ToolTip = 'Specifies the value of the Unit of Measure Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Price Includes VAT"; Rec."Price Includes VAT")
                {

                    ToolTip = 'Specifies the value of the Price Includes VAT field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount value"; Rec.Amount)
                {

                    ToolTip = 'Specifies the value of the Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code"; Rec."Currency Code")
                {

                    ToolTip = 'Specifies the value of the Currency Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Type"; Rec."Discount Type")
                {

                    ToolTip = 'Specifies the value of the Discount Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount %"; Rec."Discount %")
                {

                    ToolTip = 'Specifies the value of the Discount % field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {

                    ToolTip = 'Specifies the value of the Discount field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Code"; Rec."Discount Code")
                {

                    ToolTip = 'Specifies the value of the Discount Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Authorised by"; Rec."Discount Authorised by")
                {

                    ToolTip = 'Specifies the value of the Discount Authorised by field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Price Group value"; Rec."Customer Price Group")
                {

                    ToolTip = 'Specifies the value of the Customer Price Group field';
                    ApplicationArea = NPRRetail;
                }
                field("EFT Approved"; Rec."EFT Approved")
                {

                    ToolTip = 'Specifies the value of the Electronic Funds Transfer Approved field';
                    ApplicationArea = NPRRetail;
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
