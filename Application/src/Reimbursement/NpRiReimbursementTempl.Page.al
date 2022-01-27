page 6151101 "NPR NpRi Reimbursement Templ."
{
    Extensible = False;

    Caption = 'Reimbursement Templates';
    PageType = List;
    SourceTable = "NPR NpRi Reimbursement Templ.";
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
                field("Data Collection Module"; Rec."Data Collection Module")
                {

                    ToolTip = 'Specifies the value of the Data Collection Module field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        SetHasDataCollectionFilters();
                    end;
                }
                field("Data Collection Description"; Rec."Data Collection Description")
                {

                    ToolTip = 'Specifies the value of the Data Collection Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Data Collection Summary"; Rec."Data Collection Summary")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Data Collection Summary field';
                    ApplicationArea = NPRRetail;
                }
                field("Reimbursement Module"; Rec."Reimbursement Module")
                {

                    ToolTip = 'Specifies the value of the Reimbursement Module field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        SetHasReimbursementParameters();
                    end;
                }
                field("Reimbursement Description"; Rec."Reimbursement Description")
                {

                    ToolTip = 'Specifies the value of the Reimbursement Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Reimbursement Summary"; Rec."Reimbursement Summary")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Reimbursement Summary field';
                    ApplicationArea = NPRRetail;
                }
                field("Posting Description"; Rec."Posting Description")
                {

                    ToolTip = 'Specifies the value of the Posting Description field';
                    ApplicationArea = NPRRetail;
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = HasDataCollectionFilters;

                ToolTip = 'Executes the Data Collection Filters action';
                ApplicationArea = NPRRetail;

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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = HasReimbursementParameters;

                ToolTip = 'Executes the Reimbursement Parameters action';
                ApplicationArea = NPRRetail;

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

