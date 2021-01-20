page 6150690 "NPR NPRE Kitchen Req. Subpage"
{
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
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Request No. field';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field("Production Restaurant Code"; Rec."Production Restaurant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Production Restaurant Code field';
                }
                field("Kitchen Station"; Rec."Kitchen Station")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Kitchen Station field';
                }
                field("Production Status"; Rec."Production Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Production Status field';
                }
                field("Start Date-Time"; Rec."Start Date-Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Start Date-Time field';
                }
                field("End Date-Time"; Rec."End Date-Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the End Date-Time field';
                }
                field("Qty. Change Not Accepted"; Rec."Qty. Change Not Accepted")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Qty. Change Not Accepted field';
                }
                field("Last Qty. Change Accepted"; Rec."Last Qty. Change Accepted")
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