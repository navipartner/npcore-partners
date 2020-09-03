page 6150690 "NPR NPRE Kitchen Req. Subpage"
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant
    // NPR5.55/ALPO/20200803 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'Kitchen Request Stations';
    Editable = false;
    PageType = ListPart;
    ShowFilter = false;
    SourceTable = "NPR NPRE Kitchen Req. Station";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Request No."; "Request No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Production Restaurant Code"; "Production Restaurant Code")
                {
                    ApplicationArea = All;
                }
                field("Kitchen Station"; "Kitchen Station")
                {
                    ApplicationArea = All;
                }
                field("Production Status"; "Production Status")
                {
                    ApplicationArea = All;
                }
                field("Start Date-Time"; "Start Date-Time")
                {
                    ApplicationArea = All;
                }
                field("End Date-Time"; "End Date-Time")
                {
                    ApplicationArea = All;
                }
                field("Qty. Change Not Accepted"; "Qty. Change Not Accepted")
                {
                    ApplicationArea = All;
                }
                field("Last Qty. Change Accepted"; "Last Qty. Change Accepted")
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
            action(StartProduction)
            {
                Caption = 'Start Production';
                Image = Start;
                Visible = NOT IsExpediteMode;

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
                Visible = NOT IsExpediteMode;

                trigger OnAction()
                begin
                    KitchenOrderMgt.EndProduction(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(AcceptQtyChange)
            {
                Caption = 'Accept Qty. Change';
                Image = Approve;
                Visible = NOT IsExpediteMode;

                trigger OnAction()
                begin
                    KitchenOrderMgt.AcceptQtyChange(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        IsExpediteMode := ViewMode = ViewMode::Expedite;
    end;

    var
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        ViewMode: Option Expedite,"Kitchen Station";
        IsExpediteMode: Boolean;

    procedure SetViewMode(NewViewMode: Option)
    begin
        ViewMode := NewViewMode;
    end;
}

