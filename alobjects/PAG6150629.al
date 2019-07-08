page 6150629 "POS Workshift Checkpoints"
{
    // NPR5.41/TSA /20180417 CASE 311540 Added Entry No field visible false
    // NPR5.48/MMV /20180606 CASE 318028 Added field 'Type' and action 'Archive'
    // NPR5.50/TSA /20190424 CASE 352319 Made all fields visible

    Caption = 'Workshift Summary';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "POS Workshift Checkpoint";
    SourceTableView = SORTING("Entry No.")
                      ORDER(Descending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                }
                field("POS Unit No.";"POS Unit No.")
                {
                }
                field("Created At";"Created At")
                {
                }
                field(Open;Open)
                {
                }
                field("POS Entry No.";"POS Entry No.")
                {
                }
                field(Type;Type)
                {
                }
                field("Consolidated With Entry No.";"Consolidated With Entry No.")
                {
                }
                field("Debtor Payment (LCY)";"Debtor Payment (LCY)")
                {
                }
                field("GL Payment (LCY)";"GL Payment (LCY)")
                {
                }
                field("Rounding (LCY)";"Rounding (LCY)")
                {
                }
                field("Credit Item Sales (LCY)";"Credit Item Sales (LCY)")
                {
                }
                field("Credit Item Quantity Sum";"Credit Item Quantity Sum")
                {
                }
                field("Credit Net Sales Amount (LCY)";"Credit Net Sales Amount (LCY)")
                {
                }
                field("Credit Sales Count";"Credit Sales Count")
                {
                }
                field("Credit Sales Amount (LCY)";"Credit Sales Amount (LCY)")
                {
                }
                field("Issued Vouchers (LCY)";"Issued Vouchers (LCY)")
                {
                }
                field("Redeemed Vouchers (LCY)";"Redeemed Vouchers (LCY)")
                {
                }
                field("Local Currency (LCY)";"Local Currency (LCY)")
                {
                }
                field("Foreign Currency (LCY)";"Foreign Currency (LCY)")
                {
                }
                field("EFT (LCY)";"EFT (LCY)")
                {
                }
                field("Manual Card (LCY)";"Manual Card (LCY)")
                {
                }
                field("Other Credit Card (LCY)";"Other Credit Card (LCY)")
                {
                }
                field("Cash Terminal (LCY)";"Cash Terminal (LCY)")
                {
                }
                field("Redeemed Credit Voucher (LCY)";"Redeemed Credit Voucher (LCY)")
                {
                }
                field("Created Credit Voucher (LCY)";"Created Credit Voucher (LCY)")
                {
                }
                field("Direct Sales (LCY)";"Direct Sales (LCY)")
                {
                }
                field("Direct Sales - Staff (LCY)";"Direct Sales - Staff (LCY)")
                {
                }
                field("Direct Net Sales (LCY)";"Direct Net Sales (LCY)")
                {
                }
                field("Direct Sales Count";"Direct Sales Count")
                {
                }
                field("Cancelled Sales Count";"Cancelled Sales Count")
                {
                }
                field("Net Turnover (LCY)";"Net Turnover (LCY)")
                {
                }
                field("Turnover (LCY)";"Turnover (LCY)")
                {
                }
                field("Direct Turnover (LCY)";"Direct Turnover (LCY)")
                {
                }
                field("Direct Negative Amounts (LCY)";"Direct Negative Amounts (LCY)")
                {
                }
                field("Direct Net Turnover (LCY)";"Direct Net Turnover (LCY)")
                {
                }
                field("Net Cost (LCY)";"Net Cost (LCY)")
                {
                }
                field("Profit Amount (LCY)";"Profit Amount (LCY)")
                {
                }
                field("Profit %";"Profit %")
                {
                }
                field("Direct Return Sales (LCY)";"Direct Return Sales (LCY)")
                {
                }
                field("Direct Return Sales Line Count";"Direct Return Sales Line Count")
                {
                }
                field("Credit Real. Sale Amt. (LCY)";"Credit Real. Sale Amt. (LCY)")
                {
                }
                field("Credit Unreal. Sale Amt. (LCY)";"Credit Unreal. Sale Amt. (LCY)")
                {
                }
                field("Credit Real. Return Amt. (LCY)";"Credit Real. Return Amt. (LCY)")
                {
                }
                field("Credit Unreal. Ret. Amt. (LCY)";"Credit Unreal. Ret. Amt. (LCY)")
                {
                }
                field("Credit Turnover (LCY)";"Credit Turnover (LCY)")
                {
                }
                field("Credit Net Turnover (LCY)";"Credit Net Turnover (LCY)")
                {
                }
                field("Total Discount (LCY)";"Total Discount (LCY)")
                {
                }
                field("Total Net Discount (LCY)";"Total Net Discount (LCY)")
                {
                }
                field("Total Discount %";"Total Discount %")
                {
                }
                field("Campaign Discount (LCY)";"Campaign Discount (LCY)")
                {
                }
                field("Campaign Discount %";"Campaign Discount %")
                {
                }
                field("Mix Discount (LCY)";"Mix Discount (LCY)")
                {
                }
                field("Mix Discount %";"Mix Discount %")
                {
                }
                field("Quantity Discount (LCY)";"Quantity Discount (LCY)")
                {
                }
                field("Quantity Discount %";"Quantity Discount %")
                {
                }
                field("Custom Discount (LCY)";"Custom Discount (LCY)")
                {
                }
                field("Custom Discount %";"Custom Discount %")
                {
                }
                field("BOM Discount (LCY)";"BOM Discount (LCY)")
                {
                }
                field("BOM Discount %";"BOM Discount %")
                {
                }
                field("Customer Discount (LCY)";"Customer Discount (LCY)")
                {
                }
                field("Customer Discount %";"Customer Discount %")
                {
                }
                field("Line Discount (LCY)";"Line Discount (LCY)")
                {
                }
                field("Line Discount %";"Line Discount %")
                {
                }
                field("Calculated Diff (LCY)";"Calculated Diff (LCY)")
                {
                }
                field("Item Quantity Sum";"Item Quantity Sum")
                {
                }
                field("Item Sales Line Count";"Item Sales Line Count")
                {
                }
                field("Receipts Count";"Receipts Count")
                {
                }
                field("Cash Drawer Open Count";"Cash Drawer Open Count")
                {
                }
                field("Receipt Copies Count";"Receipt Copies Count")
                {
                }
                field("Receipt Copies Sales (LCY)";"Receipt Copies Sales (LCY)")
                {
                }
                field("Bin Transfer Out Amount (LCY)";"Bin Transfer Out Amount (LCY)")
                {
                }
                field("Bin Transfer In Amount (LCY)";"Bin Transfer In Amount (LCY)")
                {
                }
                field("Opening Cash (LCY)";"Opening Cash (LCY)")
                {
                }
                field("Perpetual Sales (LCY)";"Perpetual Sales (LCY)")
                {
                }
                field("Perpetual Return Sales (LCY)";"Perpetual Return Sales (LCY)")
                {
                }
                field("Perpetual Dir. Turnover (LCY)";"Perpetual Dir. Turnover (LCY)")
                {
                }
                field("Perpetual Dir. Neg. Amt. (LCY)";"Perpetual Dir. Neg. Amt. (LCY)")
                {
                }
                field("Perpetual Rounding Amt. (LCY)";"Perpetual Rounding Amt. (LCY)")
                {
                }
                field("POS Unit No. Filter";"POS Unit No. Filter")
                {
                }
                field("Open Filter";"Open Filter")
                {
                }
                field("POS Entry No. Filter";"POS Entry No. Filter")
                {
                }
                field("Type Filter";"Type Filter")
                {
                }
                field("FF Total Sales (LCY)";"FF Total Sales (LCY)")
                {
                }
                field("FF Total Return Sale (LCY)";"FF Total Return Sale (LCY)")
                {
                }
                field("FF Total Dir. Turnover (LCY)";"FF Total Dir. Turnover (LCY)")
                {
                }
                field("FF Total Dir. Neg. Amt. (LCY)";"FF Total Dir. Neg. Amt. (LCY)")
                {
                }
                field("FF Total Rounding Amt. (LCY)";"FF Total Rounding Amt. (LCY)")
                {
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
                RunObject = Page "POS Workshift Checkpoint Card";
                RunPageLink = "Entry No."=FIELD("Entry No.");
            }
            action(Archive)
            {
                Caption = 'Archive';
                Image = Archive;

                trigger OnAction()
                var
                    POSAuditLogMgt: Codeunit "POS Audit Log Mgt.";
                begin
                    //-NPR5.48 [318028]
                    POSAuditLogMgt.ArchiveWorkshiftPeriod(Rec);
                    //+NPR5.48 [318028]
                end;
            }
        }
    }
}

