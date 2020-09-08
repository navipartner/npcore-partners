pageextension 6014451 "NPR Purchase Order" extends "Purchase Order"
{
    layout
    {
        addafter("Job Queue Status")
        {
            field("NPR PostingDescription"; "Posting Description")
            {
                ApplicationArea = All;
            }
        }
        addafter(Control71)
        {
            field("NPR Pay-to E-mail"; "NPR Pay-to E-mail")
            {
                ApplicationArea = All;
            }
            field("NPR Document Processing"; "NPR Document Processing")
            {
                ApplicationArea = All;
            }
            field("NPR Sell-to Customer Name"; "NPR Sell-to Customer Name")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("NPR Sell-to Customer Name 2"; "NPR Sell-to Customer Name 2")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("NPR Sell-to Address"; "NPR Sell-to Address")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("NPR Sell-to Address 2"; "NPR Sell-to Address 2")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("NPR Sell-to City"; "NPR Sell-to City")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("NPR Sell-to Post Code"; "NPR Sell-to Post Code")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("NPR Sell-to Phone No."; "NPR Sell-to Phone No.")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
        addafter(Control3)
        {
            part("NPR NPAttributes"; "NPR NP Attributes FactBox")
            {
                Provider = PurchLines;
                SubPageLink = "No." = FIELD("No.");
                Visible = true;
                ApplicationArea=All;
            }
        }
        addafter(Control1905767507)
        {
            part("NPR Item Availability FactBox"; "NPR Item Availability FactBox")
            {
                Caption = 'Item Availability FactBox';
                Provider = PurchLines;
                SubPageLink = "No." = FIELD("No.");
                ApplicationArea=All;
            }
        }
    }
    actions
    {
        addafter(MoveNegativeLines)
        {
            action("NPR InsertLineVendorItem")
            {
                Caption = 'Insert Line with Vendor Item';
                Image = CoupledOrderList;
                ShortCutKey = 'Ctrl+I';
                ApplicationArea=All;
            }
            action("NPR ImportFromScanner")
            {
                Caption = 'Import from scanner';
                Image = Import;
                Promoted = true;
                ApplicationArea=All;

                trigger OnAction()
                begin
                    //-NPR5.38 [296801]
                    //+NPR5.38 [296801]
                end;
            }
        }
        addafter("Create Inventor&y Put-away/Pick")
        {
            action("NPR RFID Document")
            {
                Caption = 'RFID Document';
                Image = Delivery;
                Visible = ShowCaptureService;
                ApplicationArea=All;

                trigger OnAction()
                var
                    CSRfidHeader: Record "NPR CS Rfid Header";
                begin
                    CSRfidHeader.OpenRfidSalesDoc(1, "Vendor Order No.", "Sell-to Customer No.", "No.");
                end;
            }
        }
        addafter("&Print")
        {
            action("NPR RetailPrint")
            {
                Caption = 'Retail Print';
                Ellipsis = true;
                Image = BinContent;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea=All;
            }
            action("NPR PriceLabel")
            {
                Caption = 'Price Label';
                Image = BinContent;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Shift+Ctrl+L';
                ApplicationArea=All;
            }
            group("NPR PDF2NAV")
            {
                Caption = 'PDF2NAV';
                action("NPR EmailLog")
                {
                    Caption = 'E-mail Log';
                    Image = Email;
                    ApplicationArea=All;
                }
                action("NPR SendAsPDF")
                {
                    Caption = 'Send as PDF';
                    Image = SendEmailPDF;
                    ApplicationArea=All;
                }
            }
        }
    }

    var
        ShowCaptureService: Boolean;
        CSHelperFunctions: Codeunit "NPR CS Helper Functions";


    trigger OnOpenPage()
    begin
        ShowCaptureService := CSHelperFunctions.CaptureServiceStatus();
    end;
}

