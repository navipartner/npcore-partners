page 6150629 "NPR POS Workshift Checkpoints"
{
    Caption = 'Workshift Summary';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
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
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("POS Unit No."; "POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("Created At"; "Created At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created At field';
                }
                field(Open; Open)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Open field';
                }
                field("POS Entry No."; "POS Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Entry No. field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Period Type"; "Period Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Type field';
                }
                field("Consolidated With Entry No."; "Consolidated With Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Consolidated With Entry No. field';
                }
                field("Debtor Payment (LCY)"; "Debtor Payment (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Debtor Payment (LCY) field';
                }
                field("GL Payment (LCY)"; "GL Payment (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the GL Payment (LCY) field';
                }
                field("Rounding (LCY)"; "Rounding (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding (LCY) field';
                }
                field("Credit Item Sales (LCY)"; "Credit Item Sales (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Credit Item Sales (LCY) field';
                }
                field("Credit Item Quantity Sum"; "Credit Item Quantity Sum")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Credit Item Quantity Sum field';
                }
                field("Credit Net Sales Amount (LCY)"; "Credit Net Sales Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Credit Net Sales Amount (LCY) field';
                }
                field("Credit Sales Count"; "Credit Sales Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Credit Sales Count field';
                }
                field("Credit Sales Amount (LCY)"; "Credit Sales Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Credit Sales Amount (LCY) field';
                }
                field("Issued Vouchers (LCY)"; "Issued Vouchers (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Issued Vouchers (LCY) field';
                }
                field("Redeemed Vouchers (LCY)"; "Redeemed Vouchers (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Redeemed Vouchers (LCY) field';
                }
                field("Local Currency (LCY)"; "Local Currency (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Local Currency (LCY) field';
                }
                field("Foreign Currency (LCY)"; "Foreign Currency (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Foreign Currency (LCY) field';
                }
                field("EFT (LCY)"; "EFT (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the EFT (LCY) field';
                }
                field("Manual Card (LCY)"; "Manual Card (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Manual Card (LCY) field';
                }
                field("Other Credit Card (LCY)"; "Other Credit Card (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Other Credit Card (LCY) field';
                }
                field("Cash Terminal (LCY)"; "Cash Terminal (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Terminal (LCY) field';
                }
                field("Redeemed Credit Voucher (LCY)"; "Redeemed Credit Voucher (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Redeemed Credit Voucher (LCY) field';
                }
                field("Created Credit Voucher (LCY)"; "Created Credit Voucher (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created Credit Voucher (LCY) field';
                }
                field("Direct Item Sales (LCY)"; "Direct Item Sales (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Direct Item Sales (LCY) field';
                }
                field("Direct Sales - Staff (LCY)"; "Direct Sales - Staff (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Direct Sales - Staff (LCY) field';
                }
                field("Direct Item Net Sales (LCY)"; "Direct Item Net Sales (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Direct Item Net Sales (LCY) field';
                }
                field("Direct Sales Count"; "Direct Sales Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Direct Sales Count field';
                }
                field("Cancelled Sales Count"; "Cancelled Sales Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cancelled Sales Count field';
                }
                field("Net Turnover (LCY)"; "Net Turnover (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Net Turnover (LCY) field';
                }
                field("Turnover (LCY)"; "Turnover (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Turnover (LCY) field';
                }
                field("Direct Turnover (LCY)"; "Direct Turnover (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Direct Turnover (LCY) field';
                }
                field("Direct Negative Turnover (LCY)"; "Direct Negative Turnover (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Direct Negative Turnover (LCY) field';
                }
                field("Direct Net Turnover (LCY)"; "Direct Net Turnover (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Direct Net Turnover (LCY) field';
                }
                field("Net Cost (LCY)"; "Net Cost (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Net Cost (LCY) field';
                }
                field("Profit Amount (LCY)"; "Profit Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Profit Amount (LCY) field';
                }
                field("Profit %"; "Profit %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Profit % field';
                }
                field("Direct Item Returns (LCY)"; "Direct Item Returns (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Direct Item Returns (LCY) field';
                }
                field("Direct Item Returns Line Count"; "Direct Item Returns Line Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Direct Item Returns Line Count field';
                }
                field("Credit Real. Sale Amt. (LCY)"; "Credit Real. Sale Amt. (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Credit Real. Sale Amt. (LCY) field';
                }
                field("Credit Unreal. Sale Amt. (LCY)"; "Credit Unreal. Sale Amt. (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Credit Unreal. Sale Amt. (LCY) field';
                }
                field("Credit Real. Return Amt. (LCY)"; "Credit Real. Return Amt. (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Credit Real. Return Amt. (LCY) field';
                }
                field("Credit Unreal. Ret. Amt. (LCY)"; "Credit Unreal. Ret. Amt. (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Credit Unreal. Ret. Amt. (LCY) field';
                }
                field("Credit Turnover (LCY)"; "Credit Turnover (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Credit Turnover (LCY) field';
                }
                field("Credit Net Turnover (LCY)"; "Credit Net Turnover (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Credit Net Turnover (LCY) field';
                }
                field("Total Discount (LCY)"; "Total Discount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total Discount (LCY) field';
                }
                field("Total Net Discount (LCY)"; "Total Net Discount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total Net Discount (LCY) field';
                }
                field("Total Discount %"; "Total Discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total Discount % field';
                }
                field("Campaign Discount (LCY)"; "Campaign Discount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Campaign Discount (LCY) field';
                }
                field("Campaign Discount %"; "Campaign Discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Campaign Discount % field';
                }
                field("Mix Discount (LCY)"; "Mix Discount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mix Discount (LCY) field';
                }
                field("Mix Discount %"; "Mix Discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mix Discount % field';
                }
                field("Quantity Discount (LCY)"; "Quantity Discount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity Discount (LCY) field';
                }
                field("Quantity Discount %"; "Quantity Discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity Discount % field';
                }
                field("Custom Discount (LCY)"; "Custom Discount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Custom Discount (LCY) field';
                }
                field("Custom Discount %"; "Custom Discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Custom Discount % field';
                }
                field("BOM Discount (LCY)"; "BOM Discount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the BOM Discount (LCY) field';
                }
                field("BOM Discount %"; "BOM Discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the BOM Discount % field';
                }
                field("Customer Discount (LCY)"; "Customer Discount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Discount (LCY) field';
                }
                field("Customer Discount %"; "Customer Discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Discount % field';
                }
                field("Line Discount (LCY)"; "Line Discount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Discount (LCY) field';
                }
                field("Line Discount %"; "Line Discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Discount % field';
                }
                field("Calculated Diff (LCY)"; "Calculated Diff (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Calculated Diff (LCY) field';
                }
                field("Direct Item Quantity Sum"; "Direct Item Quantity Sum")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Direct Item Quantity Sum field';
                }
                field("Direct Item Sales Line Count"; "Direct Item Sales Line Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Direct Item Sales Line Count field';
                }
                field("Receipts Count"; "Receipts Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipts Count field';
                }
                field("Cash Drawer Open Count"; "Cash Drawer Open Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Drawer Open Count field';
                }
                field("Receipt Copies Count"; "Receipt Copies Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt Copies Count field';
                }
                field("Receipt Copies Sales (LCY)"; "Receipt Copies Sales (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt Copies Sales (LCY) field';
                }
                field("Bin Transfer Out Amount (LCY)"; "Bin Transfer Out Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bin Transfer Out Amount (LCY) field';
                }
                field("Bin Transfer In Amount (LCY)"; "Bin Transfer In Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bin Transfer In Amount (LCY) field';
                }
                field("Opening Cash (LCY)"; "Opening Cash (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Opening Cash (LCY) field';
                }
                field("Perpetual Dir. Item Sales(LCY)"; "Perpetual Dir. Item Sales(LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Perpetual Dir. Item Sales(LCY) field';
                }
                field("Perpetual Dir. Item Ret. (LCY)"; "Perpetual Dir. Item Ret. (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Perpetual Dir. Item Ret. (LCY) field';
                }
                field("Perpetual Dir. Turnover (LCY)"; "Perpetual Dir. Turnover (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Perpetual Dir. Turnover (LCY) field';
                }
                field("Perpetual Dir. Neg. Turn (LCY)"; "Perpetual Dir. Neg. Turn (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Perpetual Dir. Neg. Turn (LCY) field';
                }
                field("Perpetual Rounding Amt. (LCY)"; "Perpetual Rounding Amt. (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Perpetual Rounding Amt. (LCY) field';
                }
                field("POS Unit No. Filter"; "POS Unit No. Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. Filter field';
                }
                field("Open Filter"; "Open Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Open Filter field';
                }
                field("POS Entry No. Filter"; "POS Entry No. Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Entry No. Filter field';
                }
                field("Type Filter"; "Type Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type Filter field';
                }
                field("FF Total Dir. Item Sales (LCY)"; "FF Total Dir. Item Sales (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the FF Total Dir. Item Sales (LCY) field';
                }
                field("FF Total Dir. Item Return(LCY)"; "FF Total Dir. Item Return(LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the FF Total Dir. Item Return (LCY) field';
                }
                field("FF Total Dir. Turnover (LCY)"; "FF Total Dir. Turnover (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the FF Total Dir. Turnover (LCY) field';
                }
                field("FF Total Dir. Neg. Turn. (LCY)"; "FF Total Dir. Neg. Turn. (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the FF Total Dir. Neg. Turn. (LCY) field';
                }
                field("FF Total Rounding Amt. (LCY)"; "FF Total Rounding Amt. (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the FF Total Rounding Amt. (LCY) field';
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
                ToolTip = 'Executes the Workshift Card action';
            }
            action(Archive)
            {
                Caption = 'Archive';
                Image = Archive;
                ApplicationArea = All;
                ToolTip = 'Executes the Archive action';

                trigger OnAction()
                var
                    POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
                begin
                    POSAuditLogMgt.ArchiveWorkshiftPeriod(Rec);
                end;
            }
        }
    }
}

