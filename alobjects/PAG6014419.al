page 6014419 "Gift Voucher"
{
    // // 18-07/05 NE
    //    Tilf�jet kommentarknap
    // NC1.05 /TS  /20150223  CASE 201682 Added Web Group
    // NPR4.14/BHR /20150818  CASE 220660 Set property DeleteAllowed to "No"
    // NC2.00 /MHA /20160525  CASE 240005 NaviConnect
    // NPR5.26/TS  /20160810  CASE 248261 Renamed Action from Copy to Print Voucher and changed Image
    // NPR5.26/TS  /20160810  CASE 248243 Removed History Tab
    // NPR5.27/MMV /20161012  CASE 254299 Promoted print action.
    // MAG2.01/TR  /20161007  CASE 247244 Added action SendAsPDF
    // NPR5.29/TS  /20170117  CASE 263656 Set Promoted to Yes on Action COPY,Deleted Unused Variables

    Caption = 'Gift Voucher';
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "Gift Voucher";

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
                field("ZIP Code";"ZIP Code")
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
                          "Man. Change of Status Date" := Today;
                          "Status Changed Man. by" := UserId;
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
                    Importance = Promoted;
                }
                field("Cashed on Sales Ticket No.";"Cashed on Sales Ticket No.")
                {
                    Importance = Promoted;
                }
                field("Cashed Date";"Cashed Date")
                {
                    Importance = Promoted;
                }
                field("Cashed Salesperson";"Cashed Salesperson")
                {
                }
                field("Cashed in Global Dim 1 Code";"Cashed in Global Dim 1 Code")
                {
                }
                field("Cashed in Global Dim 2 Code";"Cashed in Global Dim 2 Code")
                {
                }
                field("Cashed in Location Code";"Cashed in Location Code")
                {
                }
                field(Invoiced;Invoiced)
                {
                    Caption = 'Invoiced';
                }
                field("Invoiced by Document Type";"Invoiced by Document Type")
                {
                    Caption = 'Inv. on doc. type';
                }
                field("Invoiced by Document No.";"Invoiced by Document No.")
                {
                    Caption = 'Inv. on doc. no.';
                }
                field("Customer No.";"Customer No.")
                {
                    Caption = 'Customer no.';
                    LookupPageID = "Customer List";
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
                field("External Gift Voucher No.";"External Gift Voucher No.")
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
            group("&Gift Voucher")
            {
                Caption = '&Gift Voucher';
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
                    Image = AddAction;

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
                    Image = Addresses;

                    trigger OnAction()
                    begin
                        FindIssuedAuditRoll;
                    end;
                }
                action(Action58)
                {
                    Caption = 'Cashed';
                    Image = Bank;

                    trigger OnAction()
                    begin
                        FindRedeemedAuditRoll;
                    end;
                }
            }
            group("&Print")
            {
                Caption = '&Print';
                action(Copy)
                {
                    Caption = 'Copy';
                    Image = PrintVoucher;
                    Promoted = true;

                    trigger OnAction()
                    var
                        GiftVoucher: Record "Gift Voucher";
                    begin
                        TestField(Status,Status::Open);
                        GiftVoucher.FilterGroup(2);
                        GiftVoucher.SetRange("No.","No.");
                        GiftVoucher.FilterGroup(0);
                        GiftVoucher.PrintGiftVoucher(false,true);
                    end;
                }
                action(SendAsPDF)
                {
                    Caption = 'Send as PDF';
                    Image = SendEmailPDF;

                    trigger OnAction()
                    var
                        Customer: Record Customer;
                        MagentoSetup: Record "Magento Setup";
                        EmailManagement: Codeunit "E-mail Management";
                        RecRef: RecordRef;
                    begin
                        //-MAG2.01
                        if not Customer.Get("Customer No.") then
                          exit;
                        if not (MagentoSetup.Get and MagentoSetup."Gift Voucher Enabled") then
                          exit;

                        RecRef.GetTable(Rec);
                        EmailManagement.SendReport(MagentoSetup."Gift Voucher Report",RecRef,Customer."E-Mail",false);
                        //+MAG2.01
                    end;
                }
            }
        }
    }
}

