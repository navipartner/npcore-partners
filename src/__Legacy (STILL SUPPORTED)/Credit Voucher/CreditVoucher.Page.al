page 6014418 "NPR Credit Voucher"
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
    SourceTable = "NPR Credit Voucher";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                    Caption = 'Post Code/City';
                    Editable = false;
                }
                field(City; City)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("No. Printed"; "No. Printed")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Salesperson; Salesperson)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Issue Date"; "Issue Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin

                        if Status <> xRec.Status then begin
                            "Status manually changed on" := Today;
                            "Status manually changed by" := UserId;
                        end;
                    end;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                }
            }
            group("Cashed In")
            {
                Caption = 'Cashed In';
                field("Cashed on Register No."; "Cashed on Register No.")
                {
                    ApplicationArea = All;
                    Caption = 'Cashed on Register No.';
                }
                field("Cashed on Sales Ticket No."; "Cashed on Sales Ticket No.")
                {
                    ApplicationArea = All;
                    Caption = 'Cashed on Sales Ticket No>';
                }
                field("Cashed Date"; "Cashed Date")
                {
                    ApplicationArea = All;
                }
                field("Cashed Salesperson"; "Cashed Salesperson")
                {
                    ApplicationArea = All;
                    Caption = 'Cashed Salesperson';
                }
                field("Cashed in Global Dim 1 Code"; "Cashed in Global Dim 1 Code")
                {
                    ApplicationArea = All;
                    Caption = 'Cashed in Department Code';
                }
                field("Cashed in Global Dim 2 Code"; "Cashed in Global Dim 2 Code")
                {
                    ApplicationArea = All;
                }
                field("Cashed in Location Code"; "Cashed in Location Code")
                {
                    ApplicationArea = All;
                    Caption = 'Cashed in Location Code';
                }
                field(Invoiced; Invoiced)
                {
                    ApplicationArea = All;
                    Caption = 'Invoiced';
                }
                field("Invoiced on enclosure"; "Invoiced on enclosure")
                {
                    ApplicationArea = All;
                    Caption = 'Inv. on doc. type';
                }
                field("Invoiced on enclosure no."; "Invoiced on enclosure no.")
                {
                    ApplicationArea = All;
                    Caption = 'Inv. on doc. no.';
                }
                field("Customer No"; "Customer No")
                {
                    ApplicationArea = All;
                    Caption = 'Customer No.';
                }
                field(Reference; Reference)
                {
                    ApplicationArea = All;
                }
                field("Cashed External"; "Cashed External")
                {
                    ApplicationArea = All;
                }
            }
            group(Magento)
            {
                Caption = 'Magento';
                field("External Credit Voucher No."; "External Credit Voucher No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("External Reference No."; "External Reference No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Expire Date"; "Expire Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Sales Order No."; "Sales Order No.")
                {
                    ApplicationArea = All;
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
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        RedeemF4;
                    end;
                }
                action("Create Invoice")
                {
                    Caption = 'Create Invoice';
                    Image = "Action";
                    ApplicationArea = All;

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
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        FindIssuedAuditRoll;
                    end;
                }
                action(Action43)
                {
                    Caption = 'Cashed';
                    Image = Allocate;
                    ApplicationArea = All;

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
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        CreditVoucher: Record "NPR Credit Voucher";
                    begin
                        //-NPR5.29
                        TestField(Status, Status::Open);
                        CreditVoucher.FilterGroup(2);
                        CreditVoucher.SetRange("No.", "No.");
                        CreditVoucher.FilterGroup(0);
                        CreditVoucher.PrintCreditVoucher(false, true);
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

