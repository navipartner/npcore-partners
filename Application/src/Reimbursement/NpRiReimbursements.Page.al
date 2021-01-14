page 6151102 "NPR NpRi Reimbursements"
{
    Caption = 'Reimbursements';
    DelayedInsert = true;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "NPR NpRi Reimbursement";
    UsageCategory = Lists;
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Party Type"; Rec."Party Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Party Type field';
                }
                field("Party No."; Rec."Party No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Party No. field';
                }
                field("Template Code"; Rec."Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Template Code field';
                }
                field("Data Collection Module"; Rec."Data Collection Module")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Data Collection Module field';
                }
                field("Data Collection Company"; Rec."Data Collection Company")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Data Collection Company field';
                }
                field("Data Collection Summary"; Rec."Data Collection Summary")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data Collection Summary field';
                }
                field("From Date"; Rec."From Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From Date field';
                }
                field("To Date"; Rec."To Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Date field';
                }
                field("Last Data Collect Entry No."; Rec."Last Data Collect Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Last Data Collect Entry No. field';
                }
                field("Last Data Collection at"; Rec."Last Data Collection at")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Data Collection at field';
                }
                field("Reimbursement Module"; Rec."Reimbursement Module")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Reimbursement Module field';
                }
                field("Reimbursement Summary"; Rec."Reimbursement Summary")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reimbursement Summary field';
                }
                field("Last Posting Date"; Rec."Last Posting Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Posting Date field';
                }
                field("Last Reimbursement at"; Rec."Last Reimbursement at")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Reimbursement at field';
                }
                field("Reimbursement Date"; Rec."Reimbursement Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reimbursement Date field';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field';
                }
                field(Balance; Rec.Balance)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balance field';
                }
                field(Deactivated; Rec.Deactivated)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Deactivated field';
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Run Data Collection action';

                trigger OnAction()
                var
                    NpRiReimbursement: Record "NPR NpRi Reimbursement";
                    NpRiDataCollectionMgt: Codeunit "NPR NpRi Data Collection Mgt.";
                begin
                    CurrPage.SetSelectionFilter(NpRiReimbursement);
                    NpRiDataCollectionMgt.RunDataCollections(NpRiReimbursement);
                    CurrPage.Update;
                end;
            }
            action("Run Reimbursement")
            {
                Caption = 'Run Reimbursement';
                Image = ExecuteAndPostBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Run Reimbursement action';

                trigger OnAction()
                var
                    NpRiReimbursement: Record "NPR NpRi Reimbursement";
                    NpRiReimbursementMgt: Codeunit "NPR NpRi Reimbursement Mgt.";
                begin
                    CurrPage.SetSelectionFilter(NpRiReimbursement);
                    NpRiReimbursementMgt.RunReimbursements(NpRiReimbursement);
                    CurrPage.Update;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Entries action';
            }
        }
    }
}

