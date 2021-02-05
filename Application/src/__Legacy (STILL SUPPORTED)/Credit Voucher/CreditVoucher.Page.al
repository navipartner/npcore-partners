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
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Address field';
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                    Caption = 'Post Code/City';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Post Code/City field';
                }
                field(City; City)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the City field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("No. Printed"; "No. Printed")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the No. Printed field';
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field';
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Cash Register No. field';
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("Issue Date"; "Issue Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Issue Date field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';

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
                    ToolTip = 'Specifies the value of the Blocked field';
                }
            }
            group("Cashed In")
            {
                Caption = 'Cashed In';
                field("Cashed on Register No."; "Cashed on Register No.")
                {
                    ApplicationArea = All;
                    Caption = 'Cashed on Register No.';
                    ToolTip = 'Specifies the value of the Cashed on Register No. field';
                }
                field("Cashed on Sales Ticket No."; "Cashed on Sales Ticket No.")
                {
                    ApplicationArea = All;
                    Caption = 'Cashed on Sales Ticket No>';
                    ToolTip = 'Specifies the value of the Cashed on Sales Ticket No> field';
                }
                field("Cashed Date"; "Cashed Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cashed Date field';
                }
                field("Cashed Salesperson"; "Cashed Salesperson")
                {
                    ApplicationArea = All;
                    Caption = 'Cashed Salesperson';
                    ToolTip = 'Specifies the value of the Cashed Salesperson field';
                }
                field("Cashed in Global Dim 1 Code"; "Cashed in Global Dim 1 Code")
                {
                    ApplicationArea = All;
                    Caption = 'Cashed in Department Code';
                    ToolTip = 'Specifies the value of the Cashed in Department Code field';
                }
                field("Cashed in Global Dim 2 Code"; "Cashed in Global Dim 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cashed in Department Code field';
                }
                field("Cashed in Location Code"; "Cashed in Location Code")
                {
                    ApplicationArea = All;
                    Caption = 'Cashed in Location Code';
                    ToolTip = 'Specifies the value of the Cashed in Location Code field';
                }
                field(Invoiced; Invoiced)
                {
                    ApplicationArea = All;
                    Caption = 'Invoiced';
                    ToolTip = 'Specifies the value of the Invoiced field';
                }
                field("Invoiced on enclosure"; "Invoiced on enclosure")
                {
                    ApplicationArea = All;
                    Caption = 'Inv. on doc. type';
                    ToolTip = 'Specifies the value of the Inv. on doc. type field';
                }
                field("Invoiced on enclosure no."; "Invoiced on enclosure no.")
                {
                    ApplicationArea = All;
                    Caption = 'Inv. on doc. no.';
                    ToolTip = 'Specifies the value of the Inv. on doc. no. field';
                }
                field("Customer No"; "Customer No")
                {
                    ApplicationArea = All;
                    Caption = 'Customer No.';
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field(Reference; Reference)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference field';
                }
                field("Cashed External"; "Cashed External")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cashed External field';
                }
            }
            group(Magento)
            {
                Caption = 'Magento';
                field("External Credit Voucher No."; "External Credit Voucher No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the External Credit Voucher No. field';
                }
                field("External Reference No."; "External Reference No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the External Reference No. field';
                }
                field("Expire Date"; "Expire Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Expire Date field';
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field("Sales Order No."; "Sales Order No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Sales Order No. field';
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
                    ToolTip = 'Executes the Cashed action';

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
                    ToolTip = 'Executes the Create Invoice action';

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
                    ToolTip = 'Executes the Issued action';

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
                    ToolTip = 'Executes the Cashed action';

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
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Copy action';

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

