page 6150690 "NPR NPRE Kitchen Req. Subpage"
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant
    // NPR5.55/ALPO/20200803 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'Kitchen Request Stations';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Request No. field';
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field("Production Restaurant Code"; "Production Restaurant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Production Restaurant Code field';
                }
                field("Kitchen Station"; "Kitchen Station")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Kitchen Station field';
                }
                field("Production Status"; "Production Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Production Status field';
                }
                field("Start Date-Time"; "Start Date-Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Start Date-Time field';
                }
                field("End Date-Time"; "End Date-Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the End Date-Time field';
                }
                field("Qty. Change Not Accepted"; "Qty. Change Not Accepted")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Qty. Change Not Accepted field';
                }
                field("Last Qty. Change Accepted"; "Last Qty. Change Accepted")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Qty. Change Accepted field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Start Production action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the End Production action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Accept Qty. Change action';

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

