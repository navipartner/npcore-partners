pageextension 6014409 "NPR Posted Purchase Receipt" extends "Posted Purchase Receipt"
{
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Added Action Items: EmailLog and SendAsPDF.
    //   - Added Permission for Modify.
    //   - Added Field 6014414 "Bill-to E-mail" for defining Recipient when sending E-mail using PDF2NAV (Billing-page).
    //   - Added Field 6014415 "Document Processing" for defining Print action on Sales Doc. Posting (Billing-page).
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)
    // PN1.10/MHA/20160314 CASE 236653 Updated Record Specific Pdf2Nav functions with general Variant functions
    // NPR5.42/THRO/20180518 CASE 308179 Removed code from Action SendAsPdf and EmailLog

    //Unsupported feature: Property Insertion (Permissions) on ""Posted Purchase Receipt"(Page 136)".

    layout
    {
        addafter("Pay-to")
        {
            field("NPR Pay-to E-mail"; "NPR Pay-to E-mail")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Pay-to E-mail field';
            }
            field("NPR Document Processing"; "NPR Document Processing")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the value of the NPR Document Processing field';
            }
        }
    }
    actions
    {
        addafter("&Navigate")
        {
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
                trigger OnAction()
                var
                    LabelLibrarySubMgt: Codeunit "NPR Label Library Sub. Mgt.";
                begin
                    LabelLibrarySubMgt.ChooseLabel(Rec);
                end;
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
                trigger OnAction()
                var
                    LabelLibrarySubMgt: Codeunit "NPR Label Library Sub. Mgt.";
                    ReportSelectionRetail: Record "NPR Report Selection Retail";
                begin
                    LabelLibrarySubMgt.PrintLabel(Rec, ReportSelectionRetail."Report Type"::"Price Label");
                end;
            }
        }
    }
}

