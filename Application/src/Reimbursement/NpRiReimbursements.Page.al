page 6151102 "NPR NpRi Reimbursements"
{
    Extensible = False;
    Caption = 'Reimbursements';
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

                    ToolTip = 'Specifies the value of the Party Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Party No."; Rec."Party No.")
                {

                    ToolTip = 'Specifies the value of the Party No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Template Code"; Rec."Template Code")
                {

                    ToolTip = 'Specifies the value of the Template Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Data Collection Module"; Rec."Data Collection Module")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Data Collection Module field';
                    ApplicationArea = NPRRetail;
                }
                field("Data Collection Company"; Rec."Data Collection Company")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Data Collection Company field';
                    ApplicationArea = NPRRetail;
                }
                field("Data Collection Summary"; Rec."Data Collection Summary")
                {

                    ToolTip = 'Specifies the value of the Data Collection Summary field';
                    ApplicationArea = NPRRetail;
                }
                field("From Date"; Rec."From Date")
                {

                    ToolTip = 'Specifies the value of the From Date field';
                    ApplicationArea = NPRRetail;
                }
                field("To Date"; Rec."To Date")
                {

                    ToolTip = 'Specifies the value of the To Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Data Collect Entry No."; Rec."Last Data Collect Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Last Data Collect Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Data Collection at"; Rec."Last Data Collection at")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Data Collection at field';
                    ApplicationArea = NPRRetail;
                }
                field("Reimbursement Module"; Rec."Reimbursement Module")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Reimbursement Module field';
                    ApplicationArea = NPRRetail;
                }
                field("Reimbursement Summary"; Rec."Reimbursement Summary")
                {

                    ToolTip = 'Specifies the value of the Reimbursement Summary field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Posting Date"; Rec."Last Posting Date")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Posting Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Reimbursement at"; Rec."Last Reimbursement at")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Reimbursement at field';
                    ApplicationArea = NPRRetail;
                }
                field("Reimbursement Date"; Rec."Reimbursement Date")
                {

                    ToolTip = 'Specifies the value of the Reimbursement Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Posting Date"; Rec."Posting Date")
                {

                    ToolTip = 'Specifies the value of the Posting Date field';
                    ApplicationArea = NPRRetail;
                }
                field(Balance; Rec.Balance)
                {

                    ToolTip = 'Specifies the value of the Balance field';
                    ApplicationArea = NPRRetail;
                }
                field(Deactivated; Rec.Deactivated)
                {

                    ToolTip = 'Specifies the value of the Deactivated field';
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

                ToolTip = 'Executes the Run Data Collection action';
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

                ToolTip = 'Executes the Run Reimbursement action';
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

                ToolTip = 'Executes the Entries action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

