page 6184502 "CleanCash Audit Roll List"
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
    SourceTable = "CleanCash Audit Roll";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Register No.";"Register No.")
                {
                }
                field("Sales Ticket No.";"Sales Ticket No.")
                {
                }
                field("Sale Date";"Sale Date")
                {
                }
                field(Type;Type)
                {
                }
                field("Receipt Type";"Receipt Type")
                {
                }
                field("Receipt Total";"Receipt Total")
                {
                }
                field("Receipt Total Neg";"Receipt Total Neg")
                {
                }
                field("Receipt Time";"Receipt Time")
                {
                }
                field(VatRate1;VatRate1)
                {
                }
                field(VatAmount1;VatAmount1)
                {
                }
                field(VatRate2;VatRate2)
                {
                }
                field(VatAmount2;VatAmount2)
                {
                }
                field(VatRate3;VatRate3)
                {
                }
                field(VatAmount3;VatAmount3)
                {
                }
                field(VatRate4;VatRate4)
                {
                }
                field(VatAmount4;VatAmount4)
                {
                }
                field("Sales Ticket Type";"Sales Ticket Type")
                {
                }
                field("Closing Time";"Closing Time")
                {
                }
                field("CleanCash Register No.";"CleanCash Register No.")
                {
                }
                field("CleanCash Reciept No.";"CleanCash Reciept No.")
                {
                }
                field("CleanCash Serial No.";"CleanCash Serial No.")
                {
                }
                field("CleanCash Control Code";"CleanCash Control Code")
                {
                }
                field("CleanCash Copy Serial No.";"CleanCash Copy Serial No.")
                {
                }
                field("CleanCash Copy Control Code";"CleanCash Copy Control Code")
                {
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

                trigger OnAction()
                var
                    CleanCashCommunication: Codeunit "CleanCash Communication";
                begin
                    CleanCashCommunication.RunMultiSalesTicket();
                end;
            }
            action("Send Receipt")
            {
                Caption = 'Send Receipt';
                Image = Start;

                trigger OnAction()
                var
                    CleanCashCommunication: Codeunit "CleanCash Communication";
                begin
                    //-NPR5.55 [409228]
                    Rec.TestField("CleanCash Control Code",'');
                    Rec.TestField("CleanCash Copy Control Code",'');
                    Rec.TestField("Receipt Type",'');
                    CleanCashCommunication.RunSingelSalesTicket(Rec."Sales Ticket No.",Rec."Register No.");
                    CurrPage.Update(false);
                    //+NPR5.55 [409228]
                end;
            }
        }
    }
}

