page 6151102 "NPR NpRi Reimbursements"
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement
    // NPR5.46/MHA /20181002  CASE 323942 Set DelayedInsert to Yes
    // NPR5.54/JKL /20191213  CASE 382066 New field 310 Deactivated added
    // NPR5.54/BHR /20200306  CASE 385924 Add fields 315, 316

    Caption = 'Reimbursements';
    DelayedInsert = true;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "NPR NpRi Reimbursement";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Party Type"; "Party Type")
                {
                    ApplicationArea = All;
                }
                field("Party No."; "Party No.")
                {
                    ApplicationArea = All;
                }
                field("Template Code"; "Template Code")
                {
                    ApplicationArea = All;
                }
                field("Data Collection Module"; "Data Collection Module")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Data Collection Company"; "Data Collection Company")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Data Collection Summary"; "Data Collection Summary")
                {
                    ApplicationArea = All;
                }
                field("From Date"; "From Date")
                {
                    ApplicationArea = All;
                }
                field("To Date"; "To Date")
                {
                    ApplicationArea = All;
                }
                field("Last Data Collect Entry No."; "Last Data Collect Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Last Data Collection at"; "Last Data Collection at")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Reimbursement Module"; "Reimbursement Module")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Reimbursement Summary"; "Reimbursement Summary")
                {
                    ApplicationArea = All;
                }
                field("Last Posting Date"; "Last Posting Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Last Reimbursement at"; "Last Reimbursement at")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Reimbursement Date"; "Reimbursement Date")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field(Balance; Balance)
                {
                    ApplicationArea = All;
                }
                field(Deactivated; Deactivated)
                {
                    ApplicationArea = All;
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
                ApplicationArea=All;

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
                ApplicationArea=All;

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
                ApplicationArea=All;
            }
        }
    }
}

