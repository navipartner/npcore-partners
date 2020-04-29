page 6150690 "NPRE Kitchen Requests Subpage"
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant

    Caption = 'Kitchen Request Stations';
    Editable = false;
    PageType = ListPart;
    SourceTable = "NPRE Kitchen Request Station";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Request No.";"Request No.")
                {
                    Visible = false;
                }
                field("Line No.";"Line No.")
                {
                    Visible = false;
                }
                field("Production Restaurant Code";"Production Restaurant Code")
                {
                }
                field("Kitchen Station";"Kitchen Station")
                {
                }
                field("Production Status";"Production Status")
                {
                }
                field("Start Date-Time";"Start Date-Time")
                {
                }
                field("End Date-Time";"End Date-Time")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(StartProduction)
            {
                Caption = 'Start Production';
                Image = Start;

                trigger OnAction()
                begin
                    KitchenOrderMgt.StartProduction(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(EndProduction)
            {
                Caption = 'End Production';
                Image = Stop;

                trigger OnAction()
                begin
                    KitchenOrderMgt.EndProduction(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        KitchenOrderMgt: Codeunit "NPRE Kitchen Order Mgt.";
}

