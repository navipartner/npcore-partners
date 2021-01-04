page 6184502 "NPR CleanCash Audit Roll List"
{

    Caption = 'CleanCash Audit Roll List';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "NPR CleanCash Audit Roll";
    UsageCategory = History;
    ApplicationArea = All;
    ObsoleteReason = 'This page is not used anymore but kept for historical purposes.';
    ObsoleteState = Pending;
    ObsoleteTag = 'CleanCash To AL';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Register No. field';
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }
                field("Sale Date"; "Sale Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sale Date field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Receipt Type"; "Receipt Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt Type field';
                }
                field("Receipt Total"; "Receipt Total")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt Total field';
                }
                field("Receipt Total Neg"; "Receipt Total Neg")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt Total Neg field';
                }
                field("Receipt Time"; "Receipt Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt Time field';
                }
                field(VatRate1; VatRate1)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vat Rate 1 field';
                }
                field(VatAmount1; VatAmount1)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vat Amount 1 field';
                }
                field(VatRate2; VatRate2)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vat Rate 2 field';
                }
                field(VatAmount2; VatAmount2)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vat Amount 2 field';
                }
                field(VatRate3; VatRate3)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vat Rate 3 field';
                }
                field(VatAmount3; VatAmount3)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vat Amount 3 field';
                }
                field(VatRate4; VatRate4)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vat Rate 4 field';
                }
                field(VatAmount4; VatAmount4)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vat Amount 4 field';
                }
                field("Sales Ticket Type"; "Sales Ticket Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket Type field';
                }
                field("Closing Time"; "Closing Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Closing Time field';
                }
                field("CleanCash Register No."; "CleanCash Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the CleanCash Cash Register No. field';
                }
                field("CleanCash Reciept No."; "CleanCash Reciept No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the CleanCash Reciept No. field';
                }
                field("CleanCash Serial No."; "CleanCash Serial No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the CleanCash Serial No. field';
                }
                field("CleanCash Control Code"; "CleanCash Control Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the CleanCash Control Code field';
                }
                field("CleanCash Copy Serial No."; "CleanCash Copy Serial No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the CleanCash Copy Serial No. field';
                }
                field("CleanCash Copy Control Code"; "CleanCash Copy Control Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the CleanCash Copy Control Code field';
                }
            }
        }
    }

}

