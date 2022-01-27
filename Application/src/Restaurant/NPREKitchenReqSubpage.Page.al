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
                    ToolTip = 'Specifies the value of the Request No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Line No."; Rec."Line No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Production Restaurant Code"; Rec."Production Restaurant Code")
                {

                    ToolTip = 'Specifies the value of the Production Restaurant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Kitchen Station"; Rec."Kitchen Station")
                {

                    ToolTip = 'Specifies the value of the Kitchen Station field';
                    ApplicationArea = NPRRetail;
                }
                field("Production Status"; Rec."Production Status")
                {

                    ToolTip = 'Specifies the value of the Production Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Start Date-Time"; Rec."Start Date-Time")
                {

                    ToolTip = 'Specifies the value of the Start Date-Time field';
                    ApplicationArea = NPRRetail;
                }
                field("End Date-Time"; Rec."End Date-Time")
                {

                    ToolTip = 'Specifies the value of the End Date-Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Qty. Change Not Accepted"; Rec."Qty. Change Not Accepted")
                {

                    ToolTip = 'Specifies the value of the Qty. Change Not Accepted field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Qty. Change Accepted"; Rec."Last Qty. Change Accepted")
                {

                    ToolTip = 'Specifies the value of the Last Qty. Change Accepted field';
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

                ToolTip = 'Executes the Start Production action';
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

                ToolTip = 'Executes the End Production action';
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

                ToolTip = 'Executes the Accept Qty. Change action';
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

    procedure SetViewMode(NewViewMode: Option)
    begin
        ViewMode := NewViewMode;
    end;
}
