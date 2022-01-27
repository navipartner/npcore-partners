page 6150681 "NPR NPRE Item Routing Profiles"
{
    Extensible = False;
    //TODO: Show assigned print/prod categories and serving steps

    Caption = 'Rest. Item Routing Profiles';
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "NPR NPRE Item Routing Profile";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(AssignedFlowStatuses; Rec.AssignedFlowStatusesAsString(FlowStatus."Status Object"::WaiterPadLineMealFlow))
                {

                    Caption = 'Serving Steps';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Serving Steps field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Rec.ShowFlowStatuses(FlowStatus."Status Object"::WaiterPadLineMealFlow);
                    end;
                }
                field(AssignedPrintCategories; Rec.AssignedPrintCategoriesAsString())
                {

                    Caption = 'Print/Prod. Categories';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Print/Prod. Categories field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Rec.ShowPrintCategories();
                    end;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(ActionGroup6014408)
            {
                action(ServingSteps)
                {
                    Caption = 'Serving Steps';
                    Enabled = RelatedInfoIsEnabled;
                    Image = CoupledOrderList;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    ToolTip = 'Executes the Serving Steps action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        FlowStatus: Record "NPR NPRE Flow Status";
                    begin
                        Rec.ShowFlowStatuses(FlowStatus."Status Object"::WaiterPadLineMealFlow);
                    end;
                }
                action(PrintCategories)
                {
                    Caption = 'Print/Prod. Categories';
                    Enabled = RelatedInfoIsEnabled;
                    Image = CoupledOrder;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    ToolTip = 'Executes the Print/Prod. Categories action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ShowPrintCategories();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        RelatedInfoIsEnabled := Rec.Code <> '';
    end;

    var
        FlowStatus: Record "NPR NPRE Flow Status";
        RelatedInfoIsEnabled: Boolean;
}
