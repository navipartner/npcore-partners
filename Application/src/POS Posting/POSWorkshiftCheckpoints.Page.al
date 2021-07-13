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
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Created At"; Rec."Created At")
                {

                    ToolTip = 'Specifies the value of the Created At field';
                    ApplicationArea = NPRRetail;
                }
                field(Open; Rec.Open)
                {

                    ToolTip = 'Specifies the value of the Open field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {

                    ToolTip = 'Specifies the value of the POS Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Period Type"; Rec."Period Type")
                {

                    ToolTip = 'Specifies the value of the Period Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Consolidated With Entry No."; Rec."Consolidated With Entry No.")
                {

                    ToolTip = 'Specifies the value of the Consolidated With Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Debtor Payment (LCY)"; Rec."Debtor Payment (LCY)")
                {

                    ToolTip = 'Specifies the value of the Debtor Payment (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("GL Payment (LCY)"; Rec."GL Payment (LCY)")
                {

                    ToolTip = 'Specifies the value of the GL Payment (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Rounding (LCY)"; Rec."Rounding (LCY)")
                {

                    ToolTip = 'Specifies the value of the Rounding (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Credit Item Sales (LCY)"; Rec."Credit Item Sales (LCY)")
                {

                    ToolTip = 'Specifies the value of the Credit Item Sales (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Credit Item Quantity Sum"; Rec."Credit Item Quantity Sum")
                {

                    ToolTip = 'Specifies the value of the Credit Item Quantity Sum field';
                    ApplicationArea = NPRRetail;
                }
                field("Credit Net Sales Amount (LCY)"; Rec."Credit Net Sales Amount (LCY)")
                {

                    ToolTip = 'Specifies the value of the Credit Net Sales Amount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Credit Sales Count"; Rec."Credit Sales Count")
                {

                    ToolTip = 'Specifies the value of the Credit Sales Count field';
                    ApplicationArea = NPRRetail;
                }
                field("Credit Sales Amount (LCY)"; Rec."Credit Sales Amount (LCY)")
                {

                    ToolTip = 'Specifies the value of the Credit Sales Amount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Issued Vouchers (LCY)"; Rec."Issued Vouchers (LCY)")
                {

                    ToolTip = 'Specifies the value of the Issued Vouchers (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Redeemed Vouchers (LCY)"; Rec."Redeemed Vouchers (LCY)")
                {

                    ToolTip = 'Specifies the value of the Redeemed Vouchers (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Local Currency (LCY)"; Rec."Local Currency (LCY)")
                {

                    ToolTip = 'Specifies the value of the Local Currency (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Foreign Currency (LCY)"; Rec."Foreign Currency (LCY)")
                {

                    ToolTip = 'Specifies the value of the Foreign Currency (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("EFT (LCY)"; Rec."EFT (LCY)")
                {

                    ToolTip = 'Specifies the value of the EFT (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Manual Card (LCY)"; Rec."Manual Card (LCY)")
                {

                    ToolTip = 'Specifies the value of the Manual Card (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Other Credit Card (LCY)"; Rec."Other Credit Card (LCY)")
                {

                    ToolTip = 'Specifies the value of the Other Credit Card (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Cash Terminal (LCY)"; Rec."Cash Terminal (LCY)")
                {

                    ToolTip = 'Specifies the value of the Cash Terminal (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Redeemed Credit Voucher (LCY)"; Rec."Redeemed Credit Voucher (LCY)")
                {

                    ToolTip = 'Specifies the value of the Redeemed Credit Voucher (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Created Credit Voucher (LCY)"; Rec."Created Credit Voucher (LCY)")
                {

                    ToolTip = 'Specifies the value of the Created Credit Voucher (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Direct Item Sales (LCY)"; Rec."Direct Item Sales (LCY)")
                {

                    ToolTip = 'Specifies the value of the Direct Item Sales (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Direct Sales - Staff (LCY)"; Rec."Direct Sales - Staff (LCY)")
                {

                    ToolTip = 'Specifies the value of the Direct Sales - Staff (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Direct Item Net Sales (LCY)"; Rec."Direct Item Net Sales (LCY)")
                {

                    ToolTip = 'Specifies the value of the Direct Item Net Sales (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Direct Sales Count"; Rec."Direct Sales Count")
                {

                    ToolTip = 'Specifies the value of the Direct Sales Count field';
                    ApplicationArea = NPRRetail;
                }
                field("Cancelled Sales Count"; Rec."Cancelled Sales Count")
                {

                    ToolTip = 'Specifies the value of the Cancelled Sales Count field';
                    ApplicationArea = NPRRetail;
                }
                field("Net Turnover (LCY)"; Rec."Net Turnover (LCY)")
                {

                    ToolTip = 'Specifies the value of the Net Turnover (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Turnover (LCY)"; Rec."Turnover (LCY)")
                {

                    ToolTip = 'Specifies the value of the Turnover (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Direct Turnover (LCY)"; Rec."Direct Turnover (LCY)")
                {

                    ToolTip = 'Specifies the value of the Direct Turnover (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Direct Negative Turnover (LCY)"; Rec."Direct Negative Turnover (LCY)")
                {

                    ToolTip = 'Specifies the value of the Direct Negative Turnover (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Direct Net Turnover (LCY)"; Rec."Direct Net Turnover (LCY)")
                {

                    ToolTip = 'Specifies the value of the Direct Net Turnover (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Net Cost (LCY)"; Rec."Net Cost (LCY)")
                {

                    ToolTip = 'Specifies the value of the Net Cost (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Profit Amount (LCY)"; Rec."Profit Amount (LCY)")
                {

                    ToolTip = 'Specifies the value of the Profit Amount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Profit %"; Rec."Profit %")
                {

                    ToolTip = 'Specifies the value of the Profit % field';
                    ApplicationArea = NPRRetail;
                }
                field("Direct Item Returns (LCY)"; Rec."Direct Item Returns (LCY)")
                {

                    ToolTip = 'Specifies the value of the Direct Item Returns (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Direct Item Returns Line Count"; Rec."Direct Item Returns Line Count")
                {

                    ToolTip = 'Specifies the value of the Direct Item Returns Line Count field';
                    ApplicationArea = NPRRetail;
                }
                field("Credit Real. Sale Amt. (LCY)"; Rec."Credit Real. Sale Amt. (LCY)")
                {

                    ToolTip = 'Specifies the value of the Credit Real. Sale Amt. (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Credit Unreal. Sale Amt. (LCY)"; Rec."Credit Unreal. Sale Amt. (LCY)")
                {

                    ToolTip = 'Specifies the value of the Credit Unreal. Sale Amt. (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Credit Real. Return Amt. (LCY)"; Rec."Credit Real. Return Amt. (LCY)")
                {

                    ToolTip = 'Specifies the value of the Credit Real. Return Amt. (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Credit Unreal. Ret. Amt. (LCY)"; Rec."Credit Unreal. Ret. Amt. (LCY)")
                {

                    ToolTip = 'Specifies the value of the Credit Unreal. Ret. Amt. (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Credit Turnover (LCY)"; Rec."Credit Turnover (LCY)")
                {

                    ToolTip = 'Specifies the value of the Credit Turnover (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Credit Net Turnover (LCY)"; Rec."Credit Net Turnover (LCY)")
                {

                    ToolTip = 'Specifies the value of the Credit Net Turnover (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Total Discount (LCY)"; Rec."Total Discount (LCY)")
                {

                    ToolTip = 'Specifies the value of the Total Discount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Total Net Discount (LCY)"; Rec."Total Net Discount (LCY)")
                {

                    ToolTip = 'Specifies the value of the Total Net Discount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Total Discount %"; Rec."Total Discount %")
                {

                    ToolTip = 'Specifies the value of the Total Discount % field';
                    ApplicationArea = NPRRetail;
                }
                field("Campaign Discount (LCY)"; Rec."Campaign Discount (LCY)")
                {

                    ToolTip = 'Specifies the value of the Campaign Discount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Campaign Discount %"; Rec."Campaign Discount %")
                {

                    ToolTip = 'Specifies the value of the Campaign Discount % field';
                    ApplicationArea = NPRRetail;
                }
                field("Mix Discount (LCY)"; Rec."Mix Discount (LCY)")
                {

                    ToolTip = 'Specifies the value of the Mix Discount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Mix Discount %"; Rec."Mix Discount %")
                {

                    ToolTip = 'Specifies the value of the Mix Discount % field';
                    ApplicationArea = NPRRetail;
                }
                field("Quantity Discount (LCY)"; Rec."Quantity Discount (LCY)")
                {

                    ToolTip = 'Specifies the value of the Quantity Discount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Quantity Discount %"; Rec."Quantity Discount %")
                {

                    ToolTip = 'Specifies the value of the Quantity Discount % field';
                    ApplicationArea = NPRRetail;
                }
                field("Custom Discount (LCY)"; Rec."Custom Discount (LCY)")
                {

                    ToolTip = 'Specifies the value of the Custom Discount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Custom Discount %"; Rec."Custom Discount %")
                {

                    ToolTip = 'Specifies the value of the Custom Discount % field';
                    ApplicationArea = NPRRetail;
                }
                field("BOM Discount (LCY)"; Rec."BOM Discount (LCY)")
                {

                    ToolTip = 'Specifies the value of the BOM Discount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("BOM Discount %"; Rec."BOM Discount %")
                {

                    ToolTip = 'Specifies the value of the BOM Discount % field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Discount (LCY)"; Rec."Customer Discount (LCY)")
                {

                    ToolTip = 'Specifies the value of the Customer Discount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Discount %"; Rec."Customer Discount %")
                {

                    ToolTip = 'Specifies the value of the Customer Discount % field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Discount (LCY)"; Rec."Line Discount (LCY)")
                {

                    ToolTip = 'Specifies the value of the Line Discount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Discount %"; Rec."Line Discount %")
                {

                    ToolTip = 'Specifies the value of the Line Discount % field';
                    ApplicationArea = NPRRetail;
                }
                field("Calculated Diff (LCY)"; Rec."Calculated Diff (LCY)")
                {

                    ToolTip = 'Specifies the value of the Calculated Diff (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Direct Item Quantity Sum"; Rec."Direct Item Quantity Sum")
                {

                    ToolTip = 'Specifies the value of the Direct Item Quantity Sum field';
                    ApplicationArea = NPRRetail;
                }
                field("Direct Item Sales Line Count"; Rec."Direct Item Sales Line Count")
                {

                    ToolTip = 'Specifies the value of the Direct Item Sales Line Count field';
                    ApplicationArea = NPRRetail;
                }
                field("Receipts Count"; Rec."Receipts Count")
                {

                    ToolTip = 'Specifies the value of the Receipts Count field';
                    ApplicationArea = NPRRetail;
                }
                field("Cash Drawer Open Count"; Rec."Cash Drawer Open Count")
                {

                    ToolTip = 'Specifies the value of the Cash Drawer Open Count field';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt Copies Count"; Rec."Receipt Copies Count")
                {

                    ToolTip = 'Specifies the value of the Receipt Copies Count field';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt Copies Sales (LCY)"; Rec."Receipt Copies Sales (LCY)")
                {

                    ToolTip = 'Specifies the value of the Receipt Copies Sales (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Bin Transfer Out Amount (LCY)"; Rec."Bin Transfer Out Amount (LCY)")
                {

                    ToolTip = 'Specifies the value of the Bin Transfer Out Amount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Bin Transfer In Amount (LCY)"; Rec."Bin Transfer In Amount (LCY)")
                {

                    ToolTip = 'Specifies the value of the Bin Transfer In Amount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Opening Cash (LCY)"; Rec."Opening Cash (LCY)")
                {

                    ToolTip = 'Specifies the value of the Opening Cash (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Perpetual Dir. Item Sales(LCY)"; Rec."Perpetual Dir. Item Sales(LCY)")
                {

                    ToolTip = 'Specifies the value of the Perpetual Dir. Item Sales(LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Perpetual Dir. Item Ret. (LCY)"; Rec."Perpetual Dir. Item Ret. (LCY)")
                {

                    ToolTip = 'Specifies the value of the Perpetual Dir. Item Ret. (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Perpetual Dir. Turnover (LCY)"; Rec."Perpetual Dir. Turnover (LCY)")
                {

                    ToolTip = 'Specifies the value of the Perpetual Dir. Turnover (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Perpetual Dir. Neg. Turn (LCY)"; Rec."Perpetual Dir. Neg. Turn (LCY)")
                {

                    ToolTip = 'Specifies the value of the Perpetual Dir. Neg. Turn (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Perpetual Rounding Amt. (LCY)"; Rec."Perpetual Rounding Amt. (LCY)")
                {

                    ToolTip = 'Specifies the value of the Perpetual Rounding Amt. (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("FF Total Dir. Item Sales (LCY)"; Rec."FF Total Dir. Item Sales (LCY)")
                {

                    ToolTip = 'Specifies the value of the FF Total Dir. Item Sales (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("FF Total Dir. Item Return(LCY)"; Rec."FF Total Dir. Item Return(LCY)")
                {

                    ToolTip = 'Specifies the value of the FF Total Dir. Item Return (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("FF Total Dir. Turnover (LCY)"; Rec."FF Total Dir. Turnover (LCY)")
                {

                    ToolTip = 'Specifies the value of the FF Total Dir. Turnover (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("FF Total Dir. Neg. Turn. (LCY)"; Rec."FF Total Dir. Neg. Turn. (LCY)")
                {

                    ToolTip = 'Specifies the value of the FF Total Dir. Neg. Turn. (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("FF Total Rounding Amt. (LCY)"; Rec."FF Total Rounding Amt. (LCY)")
                {

                    ToolTip = 'Specifies the value of the FF Total Rounding Amt. (LCY) field';
                    ApplicationArea = NPRRetail;
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Workshift Checkp. Card";
                RunPageLink = "Entry No." = FIELD("Entry No.");

                ToolTip = 'Executes the Workshift Card action';
                ApplicationArea = NPRRetail;
            }
            action(Archive)
            {
                Caption = 'Archive';
                Image = Archive;

                ToolTip = 'Executes the Archive action';
                ApplicationArea = NPRRetail;

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