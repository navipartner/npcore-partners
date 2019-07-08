page 6151102 "NpRi Reimbursements"
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement
    // NPR5.46/MHA /20181002  CASE 323942 Set DelayedInsert to Yes

    Caption = 'Reimbursements';
    DelayedInsert = true;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "NpRi Reimbursement";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Party Type";"Party Type")
                {
                }
                field("Party No.";"Party No.")
                {
                }
                field("Template Code";"Template Code")
                {
                }
                field("Data Collection Module";"Data Collection Module")
                {
                    Visible = false;
                }
                field("Data Collection Company";"Data Collection Company")
                {
                    Visible = false;
                }
                field("Data Collection Summary";"Data Collection Summary")
                {
                }
                field("Last Data Collect Entry No.";"Last Data Collect Entry No.")
                {
                    Visible = false;
                }
                field("Last Data Collection at";"Last Data Collection at")
                {
                    Editable = false;
                }
                field("Reimbursement Module";"Reimbursement Module")
                {
                    Visible = false;
                }
                field("Reimbursement Summary";"Reimbursement Summary")
                {
                }
                field("Last Posting Date";"Last Posting Date")
                {
                    Editable = false;
                }
                field("Last Reimbursement at";"Last Reimbursement at")
                {
                    Editable = false;
                }
                field("Reimbursement Date";"Reimbursement Date")
                {
                }
                field("Posting Date";"Posting Date")
                {
                }
                field(Balance;Balance)
                {
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

                trigger OnAction()
                var
                    NpRiReimbursement: Record "NpRi Reimbursement";
                    NpRiDataCollectionMgt: Codeunit "NpRi Data Collection Mgt.";
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

                trigger OnAction()
                var
                    NpRiReimbursement: Record "NpRi Reimbursement";
                    NpRiReimbursementMgt: Codeunit "NpRi Reimbursement Mgt.";
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
                RunObject = Page "NpRi Reimbursement Entries";
                RunPageLink = "Party Type"=FIELD("Party Type"),
                              "Party No."=FIELD("Party No."),
                              "Template Code"=FIELD("Template Code");
                ShortCutKey = 'Ctrl+F7';
            }
        }
    }
}

