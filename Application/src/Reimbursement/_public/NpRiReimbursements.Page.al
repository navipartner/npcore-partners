page 6151102 "NPR NpRi Reimbursements"
{
    Caption = 'Reimbursements';
    ContextSensitiveHelpPage = 'docs/retail/reimbursement/intro/';
    DelayedInsert = true;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "NPR NpRi Reimbursement";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Party Type"; Rec."Party Type")
                {
                    ToolTip = 'Specifies the party type of the reimbursement';
                    ApplicationArea = NPRRetail;
                }
                field("Party No."; Rec."Party No.")
                {
                    ToolTip = 'Specifies the party number of the reimbursement';
                    ApplicationArea = NPRRetail;
                }
                field("Template Code"; Rec."Template Code")
                {
                    ToolTip = 'Specifies the template code of the reimbursement';
                    ApplicationArea = NPRRetail;
                }
                field("Data Collection Module"; Rec."Data Collection Module")
                {

                    Visible = false;
                    ToolTip = 'Specifies the data collection module of the reimbursement';
                    ApplicationArea = NPRRetail;
                }
                field("Data Collection Company"; Rec."Data Collection Company")
                {

                    Visible = false;
                    ToolTip = 'Specifies the data collection company of the reimbursement';
                    ApplicationArea = NPRRetail;
                }
                field("Data Collection Summary"; Rec."Data Collection Summary")
                {
                    ToolTip = 'Specifies the data collection summary of the reimbursement';
                    ApplicationArea = NPRRetail;
                }
                field("From Date"; Rec."From Date")
                {
                    ToolTip = 'Specifies from which date this reimbursement is active.';
                    ApplicationArea = NPRRetail;
                }
                field("To Date"; Rec."To Date")
                {
                    ToolTip = 'Specifies the date until which this reimbursement is active.';
                    ApplicationArea = NPRRetail;
                }
                field("Last Data Collect Entry No."; Rec."Last Data Collect Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the last data collect entry number of the reimbursement';
                    ApplicationArea = NPRRetail;
                }
                field("Last Data Collection at"; Rec."Last Data Collection at")
                {

                    Editable = false;
                    ToolTip = 'Specifies when the last data collection for the reimbursement has been performed.';
                    ApplicationArea = NPRRetail;
                }
                field("Reimbursement Module"; Rec."Reimbursement Module")
                {

                    Visible = false;
                    ToolTip = 'Specifies the reimbursement module applied to the reimbursement.';
                    ApplicationArea = NPRRetail;
                }
                field("Reimbursement Summary"; Rec."Reimbursement Summary")
                {
                    ToolTip = 'Specifies the reimbursement summary of the reimbursement';
                    ApplicationArea = NPRRetail;
                }
                field("Last Posting Date"; Rec."Last Posting Date")
                {

                    Editable = false;
                    ToolTip = 'Specifies the last posting date of the reimbursement';
                    ApplicationArea = NPRRetail;
                }
                field("Last Reimbursement at"; Rec."Last Reimbursement at")
                {

                    Editable = false;
                    ToolTip = 'Specifies when the previous data reimbursement was performed.';
                    ApplicationArea = NPRRetail;
                }
                field("Reimbursement Date"; Rec."Reimbursement Date")
                {
                    ToolTip = 'Specifies the reimbursement date';
                    ApplicationArea = NPRRetail;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the posting date of the reimbursement';
                    ApplicationArea = NPRRetail;
                }
                field(Balance; Rec.Balance)
                {
                    ToolTip = 'Specifies the balance of the reimbursement';
                    ApplicationArea = NPRRetail;
                }
                field(Deactivated; Rec.Deactivated)
                {
                    ToolTip = 'Deactivate the reimbursement.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Run Data Collection")
            {
                Caption = 'Run Data Collection';
                Image = ExecuteBatch;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Run data collection for the selected reimbursement.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NpRiReimbursement: Record "NPR NpRi Reimbursement";
                    NpRiDataCollectionMgt: Codeunit "NPR NpRi Data Collection Mgt.";
                begin
                    CurrPage.SetSelectionFilter(NpRiReimbursement);
                    NpRiDataCollectionMgt.RunDataCollections(NpRiReimbursement);
                    CurrPage.Update();
                end;
            }
            action("Run Reimbursement")
            {
                Caption = 'Run Reimbursement';
                Image = ExecuteAndPostBatch;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Execute the selected reimbursement.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NpRiReimbursement: Record "NPR NpRi Reimbursement";
                    NpRiReimbursementMgt: Codeunit "NPR NpRi Reimbursement Mgt.";
                begin
                    CurrPage.SetSelectionFilter(NpRiReimbursement);
                    NpRiReimbursementMgt.RunReimbursements(NpRiReimbursement);
                    CurrPage.Update();
                end;
            }
        }
        area(navigation)
        {
            action(Entries)
            {
                Caption = 'Entries';
                Image = List;
                RunObject = Page "NPR NpRi Reimburs. Entries";
                RunPageLink = "Party Type" = FIELD("Party Type"),
                              "Party No." = FIELD("Party No."),
                              "Template Code" = FIELD("Template Code");
                ShortCutKey = 'Ctrl+F7';

                ToolTip = 'Displays the entries for the selected reimbursement.';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

