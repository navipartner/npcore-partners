page 6150690 "NPR NPRE Kitchen Req. Subpage"
{
    Extensible = False;
    Caption = 'Kitchen Request Stations';
    Editable = false;
    PageType = ListPart;
    ShowFilter = false;
    SourceTable = "NPR NPRE Kitchen Req. Station";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Request No."; Rec."Request No.")
                {
                    Visible = false;
                    ToolTip = 'Specifies the request Id this kitchen station is assigned to.';
                    ApplicationArea = NPRRetail;
                }
                field("Line No."; Rec."Line No.")
                {
                    Visible = false;
                    ToolTip = 'Specifies the line number to identify this kitchen station request.';
                    ApplicationArea = NPRRetail;
                }
                field("Production Restaurant Code"; Rec."Production Restaurant Code")
                {
                    ToolTip = 'Specifies the restaurant this request is handled by.';
                    ApplicationArea = NPRRetail;
                }
                field("Kitchen Station"; Rec."Kitchen Station")
                {
                    ToolTip = 'Specifies the kitchen station this request is handled by.';
                    ApplicationArea = NPRRetail;
                }
                field("Production Status"; Rec."Production Status")
                {
                    ToolTip = 'Specifies the production status of this kitchen station request.';
                    ApplicationArea = NPRRetail;
                }
                field("Start Date-Time"; Rec."Start Date-Time")
                {
                    ToolTip = 'Specifies the date-time production of this request started at the kitchen station.';
                    ApplicationArea = NPRRetail;
                }
                field("End Date-Time"; Rec."End Date-Time")
                {
                    ToolTip = 'Specifies the date-time production of this request ended at the kitchen station.';
                    ApplicationArea = NPRRetail;
                }
                field("Qty. Change Not Accepted"; Rec."Qty. Change Not Accepted")
                {
                    ToolTip = 'Specifies if the kitchen station has yet to accept quantity change.';
                    ApplicationArea = NPRRetail;
                }
                field("Last Qty. Change Accepted"; Rec."Last Qty. Change Accepted")
                {
                    ToolTip = 'Specifies the date-time a quantity change was accepted last.';
                    ApplicationArea = NPRRetail;
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
                ToolTip = 'Start production of selected request lines.';
                ApplicationArea = NPRRetail;

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
                ToolTip = 'End production of selected request lines.';
                ApplicationArea = NPRRetail;

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
                ToolTip = 'Accept quantity change for selected request lines.';
                ApplicationArea = NPRRetail;

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

    internal procedure SetViewMode(NewViewMode: Option)
    begin
        ViewMode := NewViewMode;
    end;
}
