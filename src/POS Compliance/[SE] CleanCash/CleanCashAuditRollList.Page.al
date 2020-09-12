page 6184502 "NPR CleanCash Audit Roll List"
{
    // NPR4.21/JHL/20160302 CASE 222417 Page created to show CleanCash Audit Roll
    // NPR5.29/JHL/20161028 CASE 256695 Created action to send not sent CleanCash receipts
    // NPR5.48/BHR /20181206 CASE 338656 Added Missing Picture to Action
    // NPR5.55/MHA /20200611  CASE 409228 Added Page Action "Send Receipt"

    Caption = 'CleanCash Audit Roll List';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "NPR CleanCash Audit Roll";
    UsageCategory = Lists;

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

    actions
    {
        area(processing)
        {
            action("Send not sent receipts")
            {
                Caption = 'Send not sent CleanCash receipts';
                Image = SendTo;
                ApplicationArea = All;

                trigger OnAction()
                var
                    CleanCashCommunication: Codeunit "NPR CleanCash Comm.";
                begin
                    CleanCashCommunication.RunMultiSalesTicket();
                end;
            }
            action("Send Receipt")
            {
                Caption = 'Send Receipt';
                Image = Start;
                ApplicationArea = All;

                trigger OnAction()
                var
                    CleanCashCommunication: Codeunit "NPR CleanCash Comm.";
                begin
                    //-NPR5.55 [409228]
                    Rec.TestField("CleanCash Control Code", '');
                    Rec.TestField("CleanCash Copy Control Code", '');
                    Rec.TestField("Receipt Type", '');
                    CleanCashCommunication.RunSingelSalesTicket(Rec."Sales Ticket No.", Rec."Register No.");
                    CurrPage.Update(false);
                    //+NPR5.55 [409228]
                end;
            }
        }
    }
}

