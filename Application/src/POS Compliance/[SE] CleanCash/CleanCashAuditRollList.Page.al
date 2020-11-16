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
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                }
                field("Sale Date"; "Sale Date")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Receipt Type"; "Receipt Type")
                {
                    ApplicationArea = All;
                }
                field("Receipt Total"; "Receipt Total")
                {
                    ApplicationArea = All;
                }
                field("Receipt Total Neg"; "Receipt Total Neg")
                {
                    ApplicationArea = All;
                }
                field("Receipt Time"; "Receipt Time")
                {
                    ApplicationArea = All;
                }
                field(VatRate1; VatRate1)
                {
                    ApplicationArea = All;
                }
                field(VatAmount1; VatAmount1)
                {
                    ApplicationArea = All;
                }
                field(VatRate2; VatRate2)
                {
                    ApplicationArea = All;
                }
                field(VatAmount2; VatAmount2)
                {
                    ApplicationArea = All;
                }
                field(VatRate3; VatRate3)
                {
                    ApplicationArea = All;
                }
                field(VatAmount3; VatAmount3)
                {
                    ApplicationArea = All;
                }
                field(VatRate4; VatRate4)
                {
                    ApplicationArea = All;
                }
                field(VatAmount4; VatAmount4)
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket Type"; "Sales Ticket Type")
                {
                    ApplicationArea = All;
                }
                field("Closing Time"; "Closing Time")
                {
                    ApplicationArea = All;
                }
                field("CleanCash Register No."; "CleanCash Register No.")
                {
                    ApplicationArea = All;
                }
                field("CleanCash Reciept No."; "CleanCash Reciept No.")
                {
                    ApplicationArea = All;
                }
                field("CleanCash Serial No."; "CleanCash Serial No.")
                {
                    ApplicationArea = All;
                }
                field("CleanCash Control Code"; "CleanCash Control Code")
                {
                    ApplicationArea = All;
                }
                field("CleanCash Copy Serial No."; "CleanCash Copy Serial No.")
                {
                    ApplicationArea = All;
                }
                field("CleanCash Copy Control Code"; "CleanCash Copy Control Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}

