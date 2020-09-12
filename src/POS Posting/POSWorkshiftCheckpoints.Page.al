page 6150629 "NPR POS Workshift Checkpoints"
{
    // NPR5.41/TSA /20180417 CASE 311540 Added Entry No field visible false
    // NPR5.48/MMV /20180606 CASE 318028 Added field 'Type' and action 'Archive'
    // NPR5.50/TSA /20190424 CASE 352319 Made all fields visible
    // NPR5.51/MMV /20190611 CASE 356076 Added field 11.

    Caption = 'Workshift Summary';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR POS Workshift Checkpoint";
    SourceTableView = SORTING("Entry No.")
                      ORDER(Descending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("POS Unit No."; "POS Unit No.")
                {
                    ApplicationArea = All;
                }
                field("Created At"; "Created At")
                {
                    ApplicationArea = All;
                }
                field(Open; Open)
                {
                    ApplicationArea = All;
                }
                field("POS Entry No."; "POS Entry No.")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Period Type"; "Period Type")
                {
                    ApplicationArea = All;
                }
                field("Consolidated With Entry No."; "Consolidated With Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Debtor Payment (LCY)"; "Debtor Payment (LCY)")
                {
                    ApplicationArea = All;
                }
                field("GL Payment (LCY)"; "GL Payment (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Rounding (LCY)"; "Rounding (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Credit Item Sales (LCY)"; "Credit Item Sales (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Credit Item Quantity Sum"; "Credit Item Quantity Sum")
                {
                    ApplicationArea = All;
                }
                field("Credit Net Sales Amount (LCY)"; "Credit Net Sales Amount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Credit Sales Count"; "Credit Sales Count")
                {
                    ApplicationArea = All;
                }
                field("Credit Sales Amount (LCY)"; "Credit Sales Amount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Issued Vouchers (LCY)"; "Issued Vouchers (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Redeemed Vouchers (LCY)"; "Redeemed Vouchers (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Local Currency (LCY)"; "Local Currency (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Foreign Currency (LCY)"; "Foreign Currency (LCY)")
                {
                    ApplicationArea = All;
                }
                field("EFT (LCY)"; "EFT (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Manual Card (LCY)"; "Manual Card (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Other Credit Card (LCY)"; "Other Credit Card (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Cash Terminal (LCY)"; "Cash Terminal (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Redeemed Credit Voucher (LCY)"; "Redeemed Credit Voucher (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Created Credit Voucher (LCY)"; "Created Credit Voucher (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Direct Item Sales (LCY)"; "Direct Item Sales (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Direct Sales - Staff (LCY)"; "Direct Sales - Staff (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Direct Item Net Sales (LCY)"; "Direct Item Net Sales (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Direct Sales Count"; "Direct Sales Count")
                {
                    ApplicationArea = All;
                }
                field("Cancelled Sales Count"; "Cancelled Sales Count")
                {
                    ApplicationArea = All;
                }
                field("Net Turnover (LCY)"; "Net Turnover (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Turnover (LCY)"; "Turnover (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Direct Turnover (LCY)"; "Direct Turnover (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Direct Negative Turnover (LCY)"; "Direct Negative Turnover (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Direct Net Turnover (LCY)"; "Direct Net Turnover (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Net Cost (LCY)"; "Net Cost (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Profit Amount (LCY)"; "Profit Amount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Profit %"; "Profit %")
                {
                    ApplicationArea = All;
                }
                field("Direct Item Returns (LCY)"; "Direct Item Returns (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Direct Item Returns Line Count"; "Direct Item Returns Line Count")
                {
                    ApplicationArea = All;
                }
                field("Credit Real. Sale Amt. (LCY)"; "Credit Real. Sale Amt. (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Credit Unreal. Sale Amt. (LCY)"; "Credit Unreal. Sale Amt. (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Credit Real. Return Amt. (LCY)"; "Credit Real. Return Amt. (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Credit Unreal. Ret. Amt. (LCY)"; "Credit Unreal. Ret. Amt. (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Credit Turnover (LCY)"; "Credit Turnover (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Credit Net Turnover (LCY)"; "Credit Net Turnover (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Total Discount (LCY)"; "Total Discount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Total Net Discount (LCY)"; "Total Net Discount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Total Discount %"; "Total Discount %")
                {
                    ApplicationArea = All;
                }
                field("Campaign Discount (LCY)"; "Campaign Discount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Campaign Discount %"; "Campaign Discount %")
                {
                    ApplicationArea = All;
                }
                field("Mix Discount (LCY)"; "Mix Discount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Mix Discount %"; "Mix Discount %")
                {
                    ApplicationArea = All;
                }
                field("Quantity Discount (LCY)"; "Quantity Discount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Quantity Discount %"; "Quantity Discount %")
                {
                    ApplicationArea = All;
                }
                field("Custom Discount (LCY)"; "Custom Discount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Custom Discount %"; "Custom Discount %")
                {
                    ApplicationArea = All;
                }
                field("BOM Discount (LCY)"; "BOM Discount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("BOM Discount %"; "BOM Discount %")
                {
                    ApplicationArea = All;
                }
                field("Customer Discount (LCY)"; "Customer Discount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Customer Discount %"; "Customer Discount %")
                {
                    ApplicationArea = All;
                }
                field("Line Discount (LCY)"; "Line Discount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Line Discount %"; "Line Discount %")
                {
                    ApplicationArea = All;
                }
                field("Calculated Diff (LCY)"; "Calculated Diff (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Direct Item Quantity Sum"; "Direct Item Quantity Sum")
                {
                    ApplicationArea = All;
                }
                field("Direct Item Sales Line Count"; "Direct Item Sales Line Count")
                {
                    ApplicationArea = All;
                }
                field("Receipts Count"; "Receipts Count")
                {
                    ApplicationArea = All;
                }
                field("Cash Drawer Open Count"; "Cash Drawer Open Count")
                {
                    ApplicationArea = All;
                }
                field("Receipt Copies Count"; "Receipt Copies Count")
                {
                    ApplicationArea = All;
                }
                field("Receipt Copies Sales (LCY)"; "Receipt Copies Sales (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Bin Transfer Out Amount (LCY)"; "Bin Transfer Out Amount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Bin Transfer In Amount (LCY)"; "Bin Transfer In Amount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Opening Cash (LCY)"; "Opening Cash (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Perpetual Dir. Item Sales(LCY)"; "Perpetual Dir. Item Sales(LCY)")
                {
                    ApplicationArea = All;
                }
                field("Perpetual Dir. Item Ret. (LCY)"; "Perpetual Dir. Item Ret. (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Perpetual Dir. Turnover (LCY)"; "Perpetual Dir. Turnover (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Perpetual Dir. Neg. Turn (LCY)"; "Perpetual Dir. Neg. Turn (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Perpetual Rounding Amt. (LCY)"; "Perpetual Rounding Amt. (LCY)")
                {
                    ApplicationArea = All;
                }
                field("POS Unit No. Filter"; "POS Unit No. Filter")
                {
                    ApplicationArea = All;
                }
                field("Open Filter"; "Open Filter")
                {
                    ApplicationArea = All;
                }
                field("POS Entry No. Filter"; "POS Entry No. Filter")
                {
                    ApplicationArea = All;
                }
                field("Type Filter"; "Type Filter")
                {
                    ApplicationArea = All;
                }
                field("FF Total Dir. Item Sales (LCY)"; "FF Total Dir. Item Sales (LCY)")
                {
                    ApplicationArea = All;
                }
                field("FF Total Dir. Item Return(LCY)"; "FF Total Dir. Item Return(LCY)")
                {
                    ApplicationArea = All;
                }
                field("FF Total Dir. Turnover (LCY)"; "FF Total Dir. Turnover (LCY)")
                {
                    ApplicationArea = All;
                }
                field("FF Total Dir. Neg. Turn. (LCY)"; "FF Total Dir. Neg. Turn. (LCY)")
                {
                    ApplicationArea = All;
                }
                field("FF Total Rounding Amt. (LCY)"; "FF Total Rounding Amt. (LCY)")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Workshift Card")
            {
                Caption = 'Workshift Card';
                Ellipsis = true;
                Image = Sales;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Workshift Checkp. Card";
                RunPageLink = "Entry No." = FIELD("Entry No.");
                ApplicationArea = All;
            }
            action(Archive)
            {
                Caption = 'Archive';
                Image = Archive;
                ApplicationArea = All;

                trigger OnAction()
                var
                    POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
                begin
                    //-NPR5.48 [318028]
                    POSAuditLogMgt.ArchiveWorkshiftPeriod(Rec);
                    //+NPR5.48 [318028]
                end;
            }
        }
    }
}

