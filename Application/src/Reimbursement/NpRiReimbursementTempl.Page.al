page 6151101 "NPR NpRi Reimbursement Templ."
{

    Caption = 'Reimbursement Templates';
    PageType = List;
    SourceTable = "NPR NpRi Reimbursement Templ.";
    UsageCategory = Administration;
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Data Collection Module"; Rec."Data Collection Module")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data Collection Module field';

                    trigger OnValidate()
                    begin
                        SetHasDataCollectionFilters();
                    end;
                }
                field("Data Collection Description"; Rec."Data Collection Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data Collection Description field';
                }
                field("Data Collection Summary"; Rec."Data Collection Summary")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Data Collection Summary field';
                }
                field("Reimbursement Module"; Rec."Reimbursement Module")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reimbursement Module field';

                    trigger OnValidate()
                    begin
                        SetHasReimbursementParameters();
                    end;
                }
                field("Reimbursement Description"; Rec."Reimbursement Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reimbursement Description field';
                }
                field("Reimbursement Summary"; Rec."Reimbursement Summary")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Reimbursement Summary field';
                }
                field("Posting Description"; Rec."Posting Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Description field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Data Collection Filters")
            {
                Caption = 'Data Collection Filters';
                Image = EditFilter;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = HasDataCollectionFilters;
                ApplicationArea = All;
                ToolTip = 'Executes the Data Collection Filters action';

                trigger OnAction()
                var
                    NpRiDataCollectionMgt: Codeunit "NPR NpRi Data Collection Mgt.";
                begin
                    NpRiDataCollectionMgt.SetupTemplateFilters(Rec);
                end;
            }
            action("Reimbursement Parameters")
            {
                Caption = 'Reimbursement Parameters';
                Image = SetupPayment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = HasReimbursementParameters;
                ApplicationArea = All;
                ToolTip = 'Executes the Reimbursement Parameters action';

                trigger OnAction()
                var
                    NpRiReimbursementMgt: Codeunit "NPR NpRi Reimbursement Mgt.";
                begin
                    NpRiReimbursementMgt.SetupTemplateParameters(Rec);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetHasDataCollectionFilters();
        SetHasReimbursementParameters();
    end;

    var
        HasDataCollectionFilters: Boolean;
        HasReimbursementParameters: Boolean;

    local procedure SetHasDataCollectionFilters()
    var
        NpRiDataCollectionMgt: Codeunit "NPR NpRi Data Collection Mgt.";
    begin
        HasDataCollectionFilters := false;
        NpRiDataCollectionMgt.HasTemplateFilters(Rec, HasDataCollectionFilters);
    end;

    local procedure SetHasReimbursementParameters()
    var
        NpRiReimbursementMgt: Codeunit "NPR NpRi Reimbursement Mgt.";
    begin
        HasReimbursementParameters := false;
        NpRiReimbursementMgt.HasTemplateParameters(Rec, HasReimbursementParameters);
    end;
}

