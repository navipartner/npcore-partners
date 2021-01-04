page 6150681 "NPR NPRE Item Routing Profiles"
{
    // NPR5.55/ALPO/20200708 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)
    // !TO DO: Show assigned print/prod categories and serving steps

    Caption = 'Rest. Item Routing Profiles';
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "NPR NPRE Item Routing Profile";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(AssignedFlowStatuses; AssignedFlowStatusesAsString(FlowStatus."Status Object"::WaiterPadLineMealFlow))
                {
                    ApplicationArea = All;
                    Caption = 'Serving Steps';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Serving Steps field';

                    trigger OnDrillDown()
                    begin
                        ShowFlowStatuses(FlowStatus."Status Object"::WaiterPadLineMealFlow);
                    end;
                }
                field(AssignedPrintCategories; AssignedPrintCategoriesAsString())
                {
                    ApplicationArea = All;
                    Caption = 'Print/Prod. Categories';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Print/Prod. Categories field';

                    trigger OnDrillDown()
                    begin
                        ShowPrintCategories();
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
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Serving Steps action';

                    trigger OnAction()
                    var
                        FlowStatus: Record "NPR NPRE Flow Status";
                    begin
                        ShowFlowStatuses(FlowStatus."Status Object"::WaiterPadLineMealFlow);
                    end;
                }
                action(PrintCategories)
                {
                    Caption = 'Print/Prod. Categories';
                    Enabled = RelatedInfoIsEnabled;
                    Image = CoupledOrder;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Print/Prod. Categories action';

                    trigger OnAction()
                    begin
                        ShowPrintCategories();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        RelatedInfoIsEnabled := Code <> '';
    end;

    var
        FlowStatus: Record "NPR NPRE Flow Status";
        RelatedInfoIsEnabled: Boolean;
}

