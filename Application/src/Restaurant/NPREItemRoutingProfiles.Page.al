page 6150681 "NPR NPRE Item Routing Profiles"
{
    Extensible = False;
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
                    ToolTip = 'Specifies a code to identify this item routing profile.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a text that describes the profile.';
                    ApplicationArea = NPRRetail;
                }
                field(AssignedFlowStatuses; Rec.AssignedFlowStatusesAsString(FlowStatus."Status Object"::WaiterPadLineMealFlow))
                {
                    Caption = 'Serving Steps';
                    Editable = false;
                    ToolTip = 'Specifies the list of assigned serving steps.';
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
                    ToolTip = 'Specifies the list of assigned item print/production categories.';
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
                    ToolTip = 'View or edit assigned serving steps for the record.';
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
                    ToolTip = 'View or edit assigned item print/production categories for the record.';
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
