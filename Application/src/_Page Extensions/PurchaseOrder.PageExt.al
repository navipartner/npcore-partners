pageextension 6014451 "NPR Purchase Order" extends "Purchase Order"
{
    layout
    {
        addafter("Job Queue Status")
        {
            field("NPR PostingDescription"; "Posting Description")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Posting Description field';
            }
        }
        addafter(Control71)
        {
            field("NPR Pay-to E-mail"; "NPR Pay-to E-mail")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Pay-to E-mail field';
            }
            field("NPR Sell-to Customer Name"; "NPR Sell-to Customer Name")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the value of the NPR Sell-to Customer Name field';
            }
            field("NPR Sell-to Customer Name 2"; "NPR Sell-to Customer Name 2")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the value of the NPR Sell-to Customer Name 2 field';
            }
            field("NPR Sell-to Address"; "NPR Sell-to Address")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the value of the NPR Sell-to Address field';
            }
            field("NPR Sell-to Address 2"; "NPR Sell-to Address 2")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the value of the NPR Sell-to Address 2 field';
            }
            field("NPR Sell-to City"; "NPR Sell-to City")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the value of the NPR Sell-to City field';
            }
            field("NPR Sell-to Post Code"; "NPR Sell-to Post Code")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the value of the NPR Sell-to Post Code field';
            }
            field("NPR Sell-to Phone No."; "NPR Sell-to Phone No.")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the value of the NPR Sell-to Phone No. field';
            }
        }
        addafter(Control3)
        {
            part("NPR NPAttributes"; "NPR NP Attributes FactBox")
            {
                Provider = PurchLines;
                SubPageLink = "No." = FIELD("No.");
                Visible = true;
                ApplicationArea = All;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Insert Line with Vendor Item action';
            }
            action("NPR ImportFromScanner")
            {
                Caption = 'Import from scanner';
                Image = Import;
                Promoted = true;
                PromotedOnly = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Import from scanner action';

                trigger OnAction()
                begin
                    //-NPR5.38 [296801]
                    //+NPR5.38 [296801]
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
                PromotedOnly = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                ToolTip = 'Executes the Retail Print action';
            }
            action("NPR PriceLabel")
            {
                Caption = 'Price Label';
                Image = BinContent;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Shift+Ctrl+L';
                ApplicationArea = All;
                ToolTip = 'Executes the Price Label action';
            }
            group("NPR PDF2NAV")
            {
                Caption = 'PDF2NAV';
                action("NPR EmailLog")
                {
                    Caption = 'E-mail Log';
                    Image = Email;
                    ApplicationArea = All;
                    ToolTip = 'Executes the E-mail Log action';
                }
                action("NPR SendAsPDF")
                {
                    Caption = 'Send as PDF';
                    Image = SendEmailPDF;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Send as PDF action';
                }
            }
        }
    }


}

