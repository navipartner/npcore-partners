page 6151101 "NpRi Reimbursement Templates"
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement

    Caption = 'Reimbursement Templates';
    PageType = List;
    SourceTable = "NpRi Reimbursement Template";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Data Collection Module";"Data Collection Module")
                {

                    trigger OnValidate()
                    begin
                        SetHasDataCollectionFilters();
                    end;
                }
                field("Data Collection Description";"Data Collection Description")
                {
                }
                field("Data Collection Summary";"Data Collection Summary")
                {
                    Editable = false;
                }
                field("Reimbursement Module";"Reimbursement Module")
                {

                    trigger OnValidate()
                    begin
                        SetHasReimbursementParameters();
                    end;
                }
                field("Reimbursement Description";"Reimbursement Description")
                {
                }
                field("Reimbursement Summary";"Reimbursement Summary")
                {
                    Editable = false;
                }
                field("Posting Description";"Posting Description")
                {
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

                trigger OnAction()
                var
                    NpRiDataCollectionMgt: Codeunit "NpRi Data Collection Mgt.";
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

                trigger OnAction()
                var
                    NpRiReimbursementMgt: Codeunit "NpRi Reimbursement Mgt.";
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
        NpRiDataCollectionMgt: Codeunit "NpRi Data Collection Mgt.";
    begin
        HasDataCollectionFilters := false;
        NpRiDataCollectionMgt.HasTemplateFilters(Rec,HasDataCollectionFilters);
    end;

    local procedure SetHasReimbursementParameters()
    var
        NpRiReimbursementMgt: Codeunit "NpRi Reimbursement Mgt.";
    begin
        HasReimbursementParameters := false;
        NpRiReimbursementMgt.HasTemplateParameters(Rec,HasReimbursementParameters);
    end;
}

