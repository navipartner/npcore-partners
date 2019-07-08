page 6014418 "Credit Voucher"
{
    // NC1.06/TS/20150223 CASE 201682  Added Web Group
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect
    // NPR5.26/TS/20160810 CASE 248261 Renamed Action from Copy to Print Voucher and changed Image
    // NPR5.26/TS/20160810 CASE 248243 Removed History Tab
    // NPR5.29/TS  20170117  CASE 263656 Set Promoted to Yes on Action COPY,Deleted Unused Variables
    // NPR5.48/JDH /20181109 CASE 334163 Removed space from Caption Customer No.

    Caption = 'Credit Voucher';
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Credit Voucher";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No.";"No.")
                {
                    Editable = false;
                }
                field(Name;Name)
                {
                    Editable = false;
                }
                field(Address;Address)
                {
                    Editable = false;
                }
                field("Post Code";"Post Code")
                {
                    Caption = 'Post Code/City';
                    Editable = false;
                }
                field(City;City)
                {
                    Editable = false;
                }
                field(Amount;Amount)
                {
                    Editable = false;
                }
                field("No. Printed";"No. Printed")
                {
                    Editable = false;
                }
                field("Shortcut Dimension 1 Code";"Shortcut Dimension 1 Code")
                {
                    Editable = false;
                }
                field("Shortcut Dimension 2 Code";"Shortcut Dimension 2 Code")
                {
                    Editable = false;
                }
                field("Register No.";"Register No.")
                {
                    Editable = false;
                }
                field("Sales Ticket No.";"Sales Ticket No.")
                {
                    Editable = false;
                }
                field(Salesperson;Salesperson)
                {
                    Editable = false;
                }
                field("Issue Date";"Issue Date")
                {
                    Editable = false;
                }
                field(Status;Status)
                {

                    trigger OnValidate()
                    begin

                        if Status <> xRec.Status then begin
                          "Status manually changed on" := Today;
                          "Status manually changed by"  := UserId;
                        end;
                    end;
                }
                field(Blocked;Blocked)
                {
                }
            }
            group("Cashed In")
            {
                Caption = 'Cashed In';
                field("Cashed on Register No.";"Cashed on Register No.")
                {
                    Caption = 'Cashed on Register No.';
                }
                field("Cashed on Sales Ticket No.";"Cashed on Sales Ticket No.")
                {
                    Caption = 'Cashed on Sales Ticket No>';
                }
                field("Cashed Date";"Cashed Date")
                {
                }
                field("Cashed Salesperson";"Cashed Salesperson")
                {
                    Caption = 'Cashed Salesperson';
                }
                field("Cashed in Global Dim 1 Code";"Cashed in Global Dim 1 Code")
                {
                    Caption = 'Cashed in Department Code';
                }
                field("Cashed in Global Dim 2 Code";"Cashed in Global Dim 2 Code")
                {
                }
                field("Cashed in Location Code";"Cashed in Location Code")
                {
                    Caption = 'Cashed in Location Code';
                }
                field(Invoiced;Invoiced)
                {
                    Caption = 'Invoiced';
                }
                field("Invoiced on enclosure";"Invoiced on enclosure")
                {
                    Caption = 'Inv. on doc. type';
                }
                field("Invoiced on enclosure no.";"Invoiced on enclosure no.")
                {
                    Caption = 'Inv. on doc. no.';
                }
                field("Customer No";"Customer No")
                {
                    Caption = 'Customer No.';
                }
                field(Reference;Reference)
                {
                }
                field("Cashed External";"Cashed External")
                {
                }
            }
            group(Magento)
            {
                Caption = 'Magento';
                field("External Credit Voucher No.";"External Credit Voucher No.")
                {
                    Editable = false;
                }
                field("External Reference No.";"External Reference No.")
                {
                    Editable = false;
                }
                field("Expire Date";"Expire Date")
                {
                    Editable = false;
                }
                field("Currency Code";"Currency Code")
                {
                    Editable = false;
                }
                field("Sales Order No.";"Sales Order No.")
                {
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Voucher")
            {
                Caption = '&Voucher';
                action(Cashed)
                {
                    Caption = 'Cashed';
                    Image = "Action";

                    trigger OnAction()
                    begin
                        RedeemF4;
                    end;
                }
                action("Create Invoice")
                {
                    Caption = 'Create Invoice';
                    Image = "Action";

                    trigger OnAction()
                    begin
                        CreateInvoice;
                    end;
                }
            }
            group("&Navigate")
            {
                Caption = '&Navigate';
                action(Issued)
                {
                    Caption = 'Issued';
                    Image = "Action";

                    trigger OnAction()
                    begin
                        FindIssuedAuditRoll;
                    end;
                }
                action(Action43)
                {
                    Caption = 'Cashed';
                    Image = Allocate;

                    trigger OnAction()
                    begin
                        FindRedeemedAuditRoll;
                    end;
                }
            }
            group("&Print")
            {
                Caption = '&Print';
                action("<Action33>")
                {
                    Caption = 'Copy';
                    Image = PrintVoucher;
                    Promoted = true;

                    trigger OnAction()
                    var
                        CreditVoucher: Record "Credit Voucher";
                    begin
                        //-NPR5.29
                        TestField( Status, Status::Open );
                        CreditVoucher.FilterGroup(2);
                        CreditVoucher.SetRange("No.","No.");
                        CreditVoucher.FilterGroup(0);
                        CreditVoucher.PrintCreditVoucher(false,true);
                        //+NPR5.29
                    end;
                }
            }
        }
    }

    var
        Text10600000: Label 'Manually';
        Text10600001: Label 'Cancelled';
}

